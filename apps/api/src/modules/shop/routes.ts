import type { FastifyInstance } from "fastify";

import {
  createShopProduct,
  createShopOrder,
  getProfile,
  getShopOrders,
  getUserIdForAccessToken,
  updateShopOrderStatus,
  updateShopProduct,
  type CreateShopProductInput,
  type CreateShopOrderInput,
  type UpdateShopOrderStatusInput,
  type UpdateShopProductInput,
} from "../../data/persistent-store.js";
import { readAccessToken } from "../shared/auth.js";

export async function registerShopRoutes(app: FastifyInstance) {
  app.get("/", async (request) => {
    const accessToken = readAccessToken(request.headers.authorization);
    const userId =
      (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

    return {
      items: await getShopOrders(userId),
    };
  });

  app.post<{ Body: CreateShopOrderInput }>("/", async (request, reply) => {
    try {
      const accessToken = readAccessToken(request.headers.authorization);
      const userId =
        (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;
      const item = await createShopOrder(request.body ?? {}, userId);
      reply.code(201);

      return {
        item,
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo generar la orden de compra.",
      };
    }
  });

  app.post<{ Body: CreateShopProductInput }>(
    "/products",
    async (request, reply) => {
      try {
        await requireSpecialist(request.headers.authorization);
        const item = await createShopProduct(request.body ?? {});
        reply.code(201);

        return {
          item,
        };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo crear el producto.",
        };
      }
    },
  );

  app.patch<{ Params: { productId: string }; Body: UpdateShopProductInput }>(
    "/products/:productId",
    async (request, reply) => {
      try {
        await requireSpecialist(request.headers.authorization);
        const item = await updateShopProduct(
          request.params.productId,
          request.body ?? {},
        );

        return {
          item,
        };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo actualizar el producto.",
        };
      }
    },
  );

  app.patch<{
    Params: { orderId: string };
    Body: UpdateShopOrderStatusInput;
  }>("/orders/:orderId", async (request, reply) => {
    try {
      const accessToken = readAccessToken(request.headers.authorization);
      const userId =
        (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;
      await requireSpecialist(request.headers.authorization);
      const item = await updateShopOrderStatus(
        request.params.orderId,
        request.body ?? {},
        userId,
      );

      return {
        item,
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo actualizar la orden.",
      };
    }
  });
}

async function requireSpecialist(authorization?: string) {
  const accessToken = readAccessToken(authorization);
  const userId = await getUserIdForAccessToken(accessToken ?? undefined);
  if (!userId) {
    throw new Error("Inicia sesión como especialista para administrar tienda.");
  }

  const user = await getProfile(userId);
  if (user.accountType !== "specialist") {
    throw new Error("Tu perfil debe estar en modo especialista.");
  }
}
