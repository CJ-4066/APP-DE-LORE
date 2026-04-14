import type { FastifyInstance } from "fastify";

import {
  cancelCurrentSubscription,
  getCurrentSubscription,
  getPaymentHistory,
  type CancelSubscriptionInput,
} from "../../data/billing-store.js";
import { requireAuthenticatedUser } from "../shared/access.js";

export async function registerSubscriptionRoutes(app: FastifyInstance) {
  app.get("/current", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return { error: "Falta el token de acceso." };
    }

    return {
      item: await getCurrentSubscription(userId),
    };
  });

  app.get("/history", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return { error: "Falta el token de acceso." };
    }

    return {
      items: (await getPaymentHistory(userId)).filter(
        (item) => item.kind === "subscription",
      ),
    };
  });

  app.post<{ Body: CancelSubscriptionInput }>("/cancel", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return { error: "Falta el token de acceso." };
    }

    try {
      return {
        item: await cancelCurrentSubscription(request.body ?? {}, userId),
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo cancelar la suscripcion.",
      };
    }
  });
}
