import type { FastifyInstance } from "fastify";

import {
  calculateHistoricalUtcOffset,
  calculateNatalChart,
  calculateNextReturns,
  calculateSynastry,
  calculateTransits,
  getUpcomingAstroEvents,
  type AstroEventsInput,
  type AstroReturnsInput,
  type AstroSynastryInput,
  type AstroTransitsInput,
  type AstroUtcOffsetInput,
  type NatalChartInput,
} from "./engine.js";

interface AstroEventsQuerystring {
  from?: string;
  latitude?: string;
  longitude?: string;
}

export async function registerAstroRoutes(app: FastifyInstance) {
  app.post<{ Body: AstroUtcOffsetInput }>(
    "/utc-offset",
    async (request, reply) => {
      try {
        const item = calculateHistoricalUtcOffset(request.body ?? {});
        reply.code(200);

        return { item };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo resolver el UTC offset histórico.",
        };
      }
    },
  );

  app.post<{ Body: NatalChartInput }>("/natal", async (request, reply) => {
    try {
      const item = await calculateNatalChart(request.body ?? {});
      reply.code(200);

      return { item };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo calcular la carta natal.",
      };
    }
  });

  app.post<{ Body: AstroTransitsInput }>("/transits", async (request, reply) => {
    try {
      const item = await calculateTransits(request.body ?? {});
      reply.code(200);

      return { item };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudieron calcular los tránsitos.",
      };
    }
  });

  app.post<{ Body: AstroReturnsInput }>("/returns", async (request, reply) => {
    try {
      const item = await calculateNextReturns(request.body ?? {});
      reply.code(200);

      return { item };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudieron calcular las revoluciones.",
      };
    }
  });

  app.post<{ Body: AstroSynastryInput }>(
    "/synastry",
    async (request, reply) => {
      try {
        const item = await calculateSynastry(request.body ?? {});
        reply.code(200);

        return { item };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo calcular la sinastría.",
        };
      }
    },
  );

  app.get<{ Querystring: AstroEventsQuerystring }>(
    "/events",
    async (request, reply) => {
      try {
        const query = request.query ?? {};
        const input: AstroEventsInput = {
          from: query.from,
          latitude:
            query.latitude === undefined ? undefined : Number(query.latitude),
          longitude:
            query.longitude === undefined ? undefined : Number(query.longitude),
        };
        const item = await getUpcomingAstroEvents(input);
        reply.code(200);

        return { item };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
            : "No se pudieron calcular los eventos astrológicos.",
        };
      }
    },
  );
}
