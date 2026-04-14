import type { FastifyInstance } from "fastify";

import {
  calculateNumerologyProfile,
  getNumerologyGuide,
  type NumerologyProfileInput,
} from "./engine.js";

export async function registerNumerologyRoutes(app: FastifyInstance) {
  app.get("/guide", async () => {
    return {
      item: getNumerologyGuide(),
    };
  });

  app.post<{ Body: NumerologyProfileInput }>(
    "/profile",
    async (request, reply) => {
      try {
        const item = calculateNumerologyProfile(request.body ?? {});
        reply.code(200);
        return { item };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo calcular el perfil de numerología.",
        };
      }
    },
  );
}
