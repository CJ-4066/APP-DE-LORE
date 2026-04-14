import type { FastifyInstance, FastifyRequest } from "fastify";

import { getUserIdForAccessToken } from "../../data/persistent-store.js";
import {
  createUploadSession,
  getFileAsset,
  getFileAssetContent,
  type CreateUploadSessionInput,
  uploadAssetBytes,
} from "../../data/storage-store.js";
import { readAccessToken } from "../shared/auth.js";

function getRequestBaseUrl(request: FastifyRequest): string {
  const forwardedProto = request.headers["x-forwarded-proto"];
  const proto =
    typeof forwardedProto === "string" && forwardedProto.trim().length > 0
      ? forwardedProto.split(",")[0].trim()
      : "http";
  const host = request.headers.host ?? "127.0.0.1:4000";
  return `${proto}://${host}`;
}

function buildPublicPath(assetId: string): string {
  return `/api/storage/assets/${assetId}/content`;
}

function serializeAsset(
  request: FastifyRequest,
  asset: Awaited<ReturnType<typeof getFileAsset>>,
) {
  return {
    ...asset,
    publicUrl: buildPublicPath(asset.id),
    resolvedPublicUrl: `${getRequestBaseUrl(request)}${buildPublicPath(asset.id)}`,
  };
}

export async function registerStorageRoutes(app: FastifyInstance) {
  app.post<{ Body: CreateUploadSessionInput }>("/uploads", async (request, reply) => {
    try {
      const accessToken = readAccessToken(request.headers.authorization);
      const userId =
        (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;
      const session = await createUploadSession(request.body ?? {}, userId);

      reply.code(201);
      return {
        item: {
          asset: serializeAsset(request, session.asset),
          uploadExpiresInSeconds: session.uploadExpiresInSeconds,
          method: session.method,
          uploadUrl: `${getRequestBaseUrl(request)}/api/storage/uploads/${session.asset.id}/binary?token=${encodeURIComponent(session.uploadToken)}`,
        },
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo crear la sesión de upload.",
      };
    }
  });

  app.put<{
    Params: { assetId: string };
    Querystring: { token?: string };
    Body: Buffer;
  }>("/uploads/:assetId/binary", async (request, reply) => {
    try {
      const token = request.query.token?.trim() ?? "";
      const contentType = request.headers["content-type"];
      const body = request.body;
      if (!Buffer.isBuffer(body)) {
        throw new Error("No se recibieron bytes válidos para el upload.");
      }

      const asset = await uploadAssetBytes({
        assetId: request.params.assetId,
        uploadToken: token,
        bytes: body,
        contentType: typeof contentType === "string" ? contentType : undefined,
      });

      return {
        item: serializeAsset(request, asset),
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error ? error.message : "No se pudo guardar el archivo.",
      };
    }
  });

  app.get<{ Params: { assetId: string } }>("/assets/:assetId", async (request, reply) => {
    try {
      return {
        item: serializeAsset(request, await getFileAsset(request.params.assetId)),
      };
    } catch (error) {
      reply.code(404);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo recuperar el archivo.",
      };
    }
  });

  app.get<{ Params: { assetId: string } }>(
    "/assets/:assetId/content",
    async (request, reply) => {
      try {
        const assetContent = await getFileAssetContent(request.params.assetId);
        reply.header("content-type", assetContent.asset.contentType);
        reply.header(
          "cache-control",
          assetContent.asset.category === "avatar"
            ? "public, max-age=86400"
            : "private, max-age=300",
        );
        return Buffer.from(assetContent.bytes);
      } catch (error) {
        reply.code(404);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo recuperar el contenido del archivo.",
        };
      }
    },
  );
}
