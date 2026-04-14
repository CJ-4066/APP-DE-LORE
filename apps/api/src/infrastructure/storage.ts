import {
  CreateBucketCommand,
  GetObjectCommand,
  HeadBucketCommand,
  PutObjectCommand,
  S3Client,
} from "@aws-sdk/client-s3";

import { getAppEnv, isStorageConfigured } from "./env.js";
import type { DependencyHealth } from "./database.js";

export { isStorageConfigured } from "./env.js";

let storageClient: S3Client | null = null;
let bucketReadyPromise: Promise<void> | null = null;

export function describeStorageError(error: unknown): string {
  if (error instanceof Error && error.message.trim().length > 0) {
    return error.message;
  }

  const candidate = error as {
    code?: string;
    aggregateErrors?: Array<{ message?: string }>;
  };
  const nestedMessage = candidate.aggregateErrors?.find(
    (item) => item.message != null && item.message.trim().length > 0,
  )?.message;

  if (nestedMessage) {
    return nestedMessage;
  }

  if ((candidate.code?.trim().length ?? 0) > 0) {
    return candidate.code!.trim();
  }

  return "No se pudo conectar al servicio de storage.";
}

function getStorageClient(): S3Client {
  const env = getAppEnv();
  if (!isStorageConfigured()) {
    throw new Error("S3/MinIO no esta configurado.");
  }

  if (!storageClient) {
    storageClient = new S3Client({
      region: env.s3Region ?? "us-east-1",
      endpoint: env.s3Endpoint ?? undefined,
      forcePathStyle: true,
      credentials: {
        accessKeyId: env.s3AccessKeyId ?? "",
        secretAccessKey: env.s3SecretAccessKey ?? "",
      },
    });
  }

  return storageClient;
}

async function ensureBucketExists(): Promise<void> {
  const env = getAppEnv();
  if (!env.s3Bucket) {
    throw new Error("S3_BUCKET no esta configurado.");
  }

  const client = getStorageClient();
  try {
    await client.send(
      new HeadBucketCommand({
        Bucket: env.s3Bucket,
      }),
    );
    return;
  } catch (error) {
    const metadata = error as { name?: string; $metadata?: { httpStatusCode?: number } };
    const statusCode = metadata.$metadata?.httpStatusCode;
    const code = metadata.name ?? "";
    const shouldCreateBucket =
      statusCode === 404 ||
      code === "NotFound" ||
      code === "NoSuchBucket";

    if (!shouldCreateBucket) {
      throw new Error(describeStorageError(error));
    }
  }

  try {
    await client.send(
      new CreateBucketCommand({
        Bucket: env.s3Bucket,
      }),
    );
  } catch (error) {
    throw new Error(describeStorageError(error));
  }
}

export async function ensureStorageReady(): Promise<void> {
  if (!isStorageConfigured()) {
    return;
  }

  if (!bucketReadyPromise) {
    bucketReadyPromise = ensureBucketExists().catch((error) => {
      bucketReadyPromise = null;
      throw error;
    });
  }

  await bucketReadyPromise;
}

export async function pingStorage(): Promise<DependencyHealth> {
  if (!isStorageConfigured()) {
    return { status: "disabled" };
  }

  try {
    await ensureStorageReady();
    return {
      status: "up",
    };
  } catch (error) {
    return {
      status: "down",
      detail: describeStorageError(error),
    };
  }
}

export async function putStorageObject(input: {
  objectKey: string;
  body: Uint8Array;
  contentType: string;
  cacheControl?: string;
  metadata?: Record<string, string>;
}): Promise<void> {
  const env = getAppEnv();
  if (!env.s3Bucket) {
    throw new Error("S3_BUCKET no esta configurado.");
  }

  await ensureStorageReady();
  try {
    await getStorageClient().send(
      new PutObjectCommand({
        Bucket: env.s3Bucket,
        Key: input.objectKey,
        Body: input.body,
        ContentType: input.contentType,
        CacheControl: input.cacheControl,
        Metadata: input.metadata,
      }),
    );
  } catch (error) {
    throw new Error(describeStorageError(error));
  }
}

export async function getStorageObjectBytes(objectKey: string): Promise<Uint8Array> {
  const env = getAppEnv();
  if (!env.s3Bucket) {
    throw new Error("S3_BUCKET no esta configurado.");
  }

  await ensureStorageReady();
  let response;
  try {
    response = await getStorageClient().send(
      new GetObjectCommand({
        Bucket: env.s3Bucket,
        Key: objectKey,
      }),
    );
  } catch (error) {
    throw new Error(describeStorageError(error));
  }

  if (!response.Body) {
    throw new Error("El objeto solicitado no existe en storage.");
  }

  return response.Body.transformToByteArray();
}
