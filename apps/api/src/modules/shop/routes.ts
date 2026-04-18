import type { FastifyInstance } from "fastify";

import {
  createShopProduct,
  createShopOrder,
  getShopOrders,
  updateShopOrderStatus,
  updateShopProduct,
  type CreateShopProductInput,
  type CreateShopOrderInput,
  type UpdateShopOrderStatusInput,
  type UpdateShopProductInput,
} from "../../data/persistent-store.js";
import {
  requireAuthenticatedUser,
  requireManagedSpecialistProfile,
  requireShopManagerAccess,
} from "../shared/access.js";

export async function registerShopRoutes(app: FastifyInstance) {
  app.get("/", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para revisar tus órdenes.",
      };
    }

    return {
      items: await getShopOrders(userId),
    };
  });

  app.post<{ Body: CreateShopOrderInput }>("/", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para crear una orden.",
      };
    }

    try {
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
      const access = await requireManagedSpecialistProfile(request, reply);
      if (!access) {
        return {
          error:
            reply.statusCode === 403
              ? "Configura tu perfil especialista para administrar tu tienda."
              : "Inicia sesión como especialista para administrar tienda.",
        };
      }

      try {
        const item = await createShopProduct(
          request.body ?? {},
          access.specialistProfileId,
        );
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
      const access = await requireManagedSpecialistProfile(request, reply);
      if (!access) {
        return {
          error:
            reply.statusCode === 403
              ? "Configura tu perfil especialista para administrar tu tienda."
              : "Inicia sesión como especialista para administrar tienda.",
        };
      }

      try {
        const item = await updateShopProduct(
          request.params.productId,
          request.body ?? {},
          {
            specialistProfileId: access.specialistProfileId,
            isAdmin: false,
          },
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
    const access = await requireShopManagerAccess(request, reply);
    if (!access) {
      return {
        error:
          reply.statusCode === 403
            ? "Necesitas permisos de especialista o usuario madre para administrar órdenes."
            : "Inicia sesión para administrar órdenes de tienda.",
      };
    }

    try {
      const item = await updateShopOrderStatus(
        request.params.orderId,
        request.body ?? {},
        access.userId,
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
