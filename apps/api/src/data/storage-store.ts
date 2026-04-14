import { randomUUID } from "node:crypto";

import type { QueryResultRow } from "pg";

import { isDatabaseConfigured, query } from "../infrastructure/database.js";
import {
  ensureStorageReady,
  getStorageObjectBytes,
  isStorageConfigured,
  putStorageObject,
} from "../infrastructure/storage.js";

const demoUserId = "user-mark";
const uploadSessionExpiresInSeconds = 10 * 60;
const avatarMaxBytes = 5 * 1024 * 1024;
const genericMaxBytes = 12 * 1024 * 1024;

export type FileAssetCategory = "avatar" | "chat_attachment" | "admin_export";
export type FileAssetStatus = "pending_upload" | "ready" | "failed";

export interface FileAsset {
  id: string;
  userId: string;
  category: FileAssetCategory;
  originalName: string;
  contentType: string;
  byteSize: number;
  storageBucket: string;
  objectKey: string;
  status: FileAssetStatus;
  createdAt: string;
  uploadedAt: string | null;
}

export interface CreateUploadSessionInput {
  filename?: string;
  contentType?: string;
  byteSize?: number;
  category?: FileAssetCategory;
}

export interface StorageUploadSession {
  asset: FileAsset;
  uploadToken: string;
  uploadExpiresInSeconds: number;
  method: "PUT";
}

interface FileAssetRow extends QueryResultRow {
  id: string;
  user_id: string;
  category: FileAssetCategory;
  original_name: string;
  content_type: string;
  byte_size: string | number;
  storage_bucket: string;
  object_key: string;
  status: FileAssetStatus;
  upload_token: string | null;
  upload_token_expires_at: Date | string | null;
  created_at: Date | string;
  uploaded_at: Date | string | null;
}

interface StoredMockAsset {
  asset: FileAsset;
  uploadToken: string | null;
  uploadTokenExpiresAt: string | null;
  content: Uint8Array | null;
}

const mockAssets = new Map<string, StoredMockAsset>();

function toIsoString(value: Date | string | null): string | null {
  if (value == null) {
    return null;
  }
  if (value instanceof Date) {
    return value.toISOString();
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return String(value);
  }

  return parsed.toISOString();
}

function sanitizeFileName(filename: string): string {
  return filename
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9.\-_]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");
}

function extractFileExtension(filename: string): string {
  const sanitized = sanitizeFileName(filename);
  const parts = sanitized.split(".");
  if (parts.length < 2) {
    return "";
  }

  const extension = parts[parts.length - 1];
  return extension.length > 10 ? "" : extension;
}

function buildObjectKey(
  userId: string,
  category: FileAssetCategory,
  filename: string,
): string {
  const extension = extractFileExtension(filename);
  const suffix = extension ? `.${extension}` : "";
  const folder =
    category === "avatar" ? "avatars" : category === "chat_attachment" ? "chat" : "exports";
  return `users/${userId}/${folder}/${randomUUID()}${suffix}`;
}

function mapFileAssetRow(row: FileAssetRow): FileAsset {
  return {
    id: row.id,
    userId: row.user_id,
    category: row.category,
    originalName: row.original_name,
    contentType: row.content_type,
    byteSize: Number(row.byte_size),
    storageBucket: row.storage_bucket,
    objectKey: row.object_key,
    status: row.status,
    createdAt: toIsoString(row.created_at) ?? new Date().toISOString(),
    uploadedAt: toIsoString(row.uploaded_at),
  };
}

function validateUploadSessionInput(input: CreateUploadSessionInput): {
  filename: string;
  contentType: string;
  byteSize: number;
  category: FileAssetCategory;
} {
  if (!isStorageConfigured()) {
    throw new Error("Storage no está configurado.");
  }

  const filename = input.filename?.trim() ?? "";
  if (filename.length < 1) {
    throw new Error("El archivo debe tener nombre.");
  }

  const contentType = input.contentType?.trim().toLowerCase() ?? "";
  if (contentType.length < 1) {
    throw new Error("El tipo de archivo es obligatorio.");
  }

  const byteSize =
    typeof input.byteSize === "number" && Number.isFinite(input.byteSize)
      ? Math.floor(input.byteSize)
      : 0;
  if (byteSize < 1) {
    throw new Error("El archivo no puede estar vacío.");
  }

  const category = input.category ?? "avatar";
  if (!["avatar", "chat_attachment", "admin_export"].includes(category)) {
    throw new Error("La categoría del archivo no es válida.");
  }

  const maxBytes = category === "avatar" ? avatarMaxBytes : genericMaxBytes;
  if (byteSize > maxBytes) {
    throw new Error(`El archivo excede el límite permitido de ${maxBytes} bytes.`);
  }

  if (category === "avatar" && !contentType.startsWith("image/")) {
    throw new Error("El avatar debe ser una imagen.");
  }

  return {
    filename,
    contentType,
    byteSize,
    category,
  };
}

function getBucketName(): string {
  return process.env.S3_BUCKET?.trim() || "lo-renaciente";
}

async function findFileAssetRow(assetId: string): Promise<FileAssetRow | null> {
  const result = await query<FileAssetRow>(
    `
      select
        id,
        user_id,
        category,
        original_name,
        content_type,
        byte_size,
        storage_bucket,
        object_key,
        status,
        upload_token,
        upload_token_expires_at,
        created_at,
        uploaded_at
      from file_assets
      where id = $1
      limit 1
    `,
    [assetId],
  );

  return result.rows[0] ?? null;
}

async function getFileAssetRecord(
  assetId: string,
): Promise<{
  asset: FileAsset;
  uploadToken: string | null;
  uploadTokenExpiresAt: string | null;
} | null> {
  if (!isDatabaseConfigured()) {
    const item = mockAssets.get(assetId);
    if (!item) {
      return null;
    }

    return {
      asset: item.asset,
      uploadToken: item.uploadToken,
      uploadTokenExpiresAt: item.uploadTokenExpiresAt,
    };
  }

  const row = await findFileAssetRow(assetId);
  if (!row) {
    return null;
  }

  return {
    asset: mapFileAssetRow(row),
    uploadToken: row.upload_token,
    uploadTokenExpiresAt: toIsoString(row.upload_token_expires_at),
  };
}

export async function createUploadSession(
  input: CreateUploadSessionInput,
  userId?: string,
): Promise<StorageUploadSession> {
  const validated = validateUploadSessionInput(input);
  await ensureStorageReady();
  const resolvedUserId = userId ?? demoUserId;
  const assetId = randomUUID();
  const uploadToken = randomUUID().replaceAll("-", "");
  const objectKey = buildObjectKey(
    resolvedUserId,
    validated.category,
    validated.filename,
  );
  const asset: FileAsset = {
    id: assetId,
    userId: resolvedUserId,
    category: validated.category,
    originalName: validated.filename,
    contentType: validated.contentType,
    byteSize: validated.byteSize,
    storageBucket: getBucketName(),
    objectKey,
    status: "pending_upload",
    createdAt: new Date().toISOString(),
    uploadedAt: null,
  };
  const uploadTokenExpiresAt = new Date(
    Date.now() + uploadSessionExpiresInSeconds * 1000,
  ).toISOString();

  if (!isDatabaseConfigured()) {
    mockAssets.set(asset.id, {
      asset,
      uploadToken,
      uploadTokenExpiresAt,
      content: null,
    });
  } else {
    await query(
      `
        insert into file_assets (
          id,
          user_id,
          category,
          original_name,
          content_type,
          byte_size,
          storage_bucket,
          object_key,
          status,
          upload_token,
          upload_token_expires_at,
          updated_at
        ) values (
          $1, $2, $3, $4, $5, $6, $7, $8, 'pending_upload', $9, $10, now()
        )
      `,
      [
        asset.id,
        asset.userId,
        asset.category,
        asset.originalName,
        asset.contentType,
        asset.byteSize,
        asset.storageBucket,
        asset.objectKey,
        uploadToken,
        uploadTokenExpiresAt,
      ],
    );
  }

  return {
    asset,
    uploadToken,
    uploadExpiresInSeconds: uploadSessionExpiresInSeconds,
    method: "PUT",
  };
}

export async function uploadAssetBytes(input: {
  assetId: string;
  uploadToken: string;
  bytes: Uint8Array;
  contentType?: string;
}): Promise<FileAsset> {
  const record = await getFileAssetRecord(input.assetId);
  if (!record) {
    throw new Error("El archivo solicitado no existe.");
  }

  if (record.asset.status !== "pending_upload") {
    throw new Error("La sesión de upload ya no está disponible.");
  }
  if (!record.uploadToken || record.uploadToken !== input.uploadToken.trim()) {
    throw new Error("El token de upload no es válido.");
  }
  if (!record.uploadTokenExpiresAt || new Date(record.uploadTokenExpiresAt).getTime() <= Date.now()) {
    throw new Error("La sesión de upload ya venció.");
  }
  if (input.bytes.byteLength < 1) {
    throw new Error("El archivo recibido está vacío.");
  }
  if (input.bytes.byteLength > record.asset.byteSize) {
    throw new Error("El archivo recibido excede el tamaño declarado.");
  }

  const effectiveContentType = (input.contentType?.trim().toLowerCase() ||
    record.asset.contentType);

  await putStorageObject({
    objectKey: record.asset.objectKey,
    body: input.bytes,
    contentType: effectiveContentType,
    cacheControl:
      record.asset.category === "avatar" ? "public, max-age=86400" : "private, max-age=300",
    metadata: {
      assetId: record.asset.id,
      userId: record.asset.userId,
      category: record.asset.category,
    },
  });

  const uploadedAt = new Date().toISOString();
  const readyAsset: FileAsset = {
    ...record.asset,
    status: "ready",
    uploadedAt,
  };

  if (!isDatabaseConfigured()) {
    const existing = mockAssets.get(record.asset.id);
    if (!existing) {
      throw new Error("El archivo solicitado no existe.");
    }

    mockAssets.set(record.asset.id, {
      asset: readyAsset,
      uploadToken: null,
      uploadTokenExpiresAt: null,
      content: input.bytes,
    });
  } else {
    await query(
      `
        update file_assets
        set status = 'ready',
            content_type = $2,
            uploaded_at = $3,
            upload_token = null,
            upload_token_expires_at = null,
            updated_at = now()
        where id = $1
      `,
      [readyAsset.id, effectiveContentType, uploadedAt],
    );
  }

  return readyAsset;
}

export async function getFileAsset(assetId: string): Promise<FileAsset> {
  const record = await getFileAssetRecord(assetId);
  if (!record) {
    throw new Error("El archivo solicitado no existe.");
  }

  return record.asset;
}

export async function getFileAssetContent(assetId: string): Promise<{
  asset: FileAsset;
  bytes: Uint8Array;
}> {
  const asset = await getFileAsset(assetId);
  if (asset.status !== "ready") {
    throw new Error("El archivo aún no está listo.");
  }

  if (!isDatabaseConfigured()) {
    const mockItem = mockAssets.get(assetId);
    if (!mockItem?.content) {
      throw new Error("El archivo solicitado no existe en memoria.");
    }

    return {
      asset,
      bytes: mockItem.content,
    };
  }

  return {
    asset,
    bytes: await getStorageObjectBytes(asset.objectKey),
  };
}
