import type { FastifyInstance } from "fastify";

import {
  confirmPayment,
  createPaymentIntent,
  getPaymentHistory,
  getPaymentsConfig,
  type ConfirmPaymentInput,
  type CreatePaymentIntentInput,
} from "../../data/billing-store.js";
import { requireAuthenticatedUser } from "../shared/access.js";

export async function registerPaymentRoutes(app: FastifyInstance) {
  app.get("/config", async () => {
    return {
      item: getPaymentsConfig(),
    };
  });

  app.get("/history", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return { error: "Falta el token de acceso." };
    }

    return {
      items: await getPaymentHistory(userId),
    };
  });

  app.post<{ Body: CreatePaymentIntentInput }>("/checkout", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return { error: "Falta el token de acceso." };
    }

    try {
      reply.code(201);
      return {
        item: await createPaymentIntent(request.body ?? {}, userId),
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error ? error.message : "No se pudo iniciar el pago.",
      };
    }
  });

  app.post<{ Params: { paymentId: string }; Body: ConfirmPaymentInput }>(
    "/:paymentId/confirm",
    async (request, reply) => {
      const userId = await requireAuthenticatedUser(request, reply);
      if (!userId) {
        return { error: "Falta el token de acceso." };
      }

      try {
        return {
          item: await confirmPayment(
            request.params.paymentId,
            request.body ?? {},
            userId,
          ),
        };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo confirmar el pago.",
        };
      }
    },
  );
}
