import type { FastifyInstance } from "fastify";

import {
  getProfile,
  type UpdateUserProfileInput,
  updateCurrentUser,
} from "../../data/persistent-store.js";
import { requireAuthenticatedUser } from "../shared/access.js";

export async function registerProfileRoutes(app: FastifyInstance) {
  app.get("/me", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para ver tu perfil.",
      };
    }

    return {
      item: await getProfile(userId),
    };
  });

  app.patch<{ Body: UpdateUserProfileInput }>("/me", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para actualizar tu perfil.",
      };
    }

    try {
      const item = await updateCurrentUser(request.body ?? {}, userId);
      reply.code(200);

      return {
        item,
      };
    } catch (error) {
      reply.code(400);

      return {
        error:
          error instanceof Error ? error.message : "No se pudo actualizar el perfil.",
      };
    }
  });
}
