import type { FastifyInstance } from "fastify";

import {
  deleteSpecialistAvailability,
  getFeaturedSpecialists,
  getSpecialistAvailability,
  getSpecialistCatalog,
  type UpsertSpecialistAvailabilityInput,
  upsertSpecialistAvailability,
} from "../../data/scheduling-store.js";

export async function registerSpecialistRoutes(app: FastifyInstance) {
  app.get("/", async () => {
    return {
      items: await getSpecialistCatalog(),
    };
  });

  app.get("/featured", async () => {
    return {
      items: await getFeaturedSpecialists(),
    };
  });

  app.get<{
    Params: { specialistId: string };
    Querystring: { from?: string; to?: string; mode?: "chat" | "audio" | "video" };
  }>("/:specialistId/availability", async (request, reply) => {
    try {
      return {
        items: await getSpecialistAvailability(request.params.specialistId, {
          from: request.query.from,
          to: request.query.to,
          mode: request.query.mode,
        }),
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo cargar la disponibilidad.",
      };
    }
  });

  app.post<{ Body: UpsertSpecialistAvailabilityInput }>(
    "/availability",
    async (request, reply) => {
      try {
        const item = await upsertSpecialistAvailability(request.body ?? {});
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
              : "No se pudo guardar la disponibilidad.",
        };
      }
    },
  );

  app.delete<{ Params: { availabilityId: string } }>(
    "/availability/:availabilityId",
    async (request, reply) => {
      try {
        await deleteSpecialistAvailability(request.params.availabilityId);
        reply.code(204);
        return null;
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo eliminar la disponibilidad.",
        };
      }
    },
  );
}
