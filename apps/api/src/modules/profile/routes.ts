import type { FastifyInstance } from "fastify";

import {
  getUserIdForAccessToken,
  getProfile,
  type UpdateUserProfileInput,
  updateCurrentUser,
} from "../../data/persistent-store.js";
import { readAccessToken } from "../shared/auth.js";

export async function registerProfileRoutes(app: FastifyInstance) {
  app.get("/me", async (request) => {
    const accessToken = readAccessToken(request.headers.authorization);
    const userId =
      (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

    return {
      item: await getProfile(userId),
    };
  });

  app.patch<{ Body: UpdateUserProfileInput }>("/me", async (request, reply) => {
    try {
      const accessToken = readAccessToken(request.headers.authorization);
      const userId =
        (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;
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
