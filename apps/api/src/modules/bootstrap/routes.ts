import type { FastifyInstance } from "fastify";

import { getBootstrap } from "../../data/persistent-store.js";
import { requireAuthenticatedUser } from "../shared/access.js";

export async function registerBootstrapRoutes(app: FastifyInstance) {
  app.get("/", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para cargar tu espacio personal.",
      };
    }

    return getBootstrap(userId);
  });
}
