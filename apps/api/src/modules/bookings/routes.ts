import type { FastifyInstance } from "fastify";

import {
  getBookings,
  type UpdateBookingInput,
  type CreateBookingInput,
} from "../../data/persistent-store.js";
import {
  createManagedBooking,
  getBookingHistory,
  getBookingPolicy,
  updateManagedBooking,
} from "../../data/scheduling-store.js";
import { requireAuthenticatedUser } from "../shared/access.js";

export async function registerBookingRoutes(app: FastifyInstance) {
  app.get("/", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para ver tus citas.",
      };
    }

    return {
      items: await getBookings(userId),
    };
  });

  app.post<{ Body: CreateBookingInput }>("/", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para reservar una cita.",
      };
    }

    try {
      const item = await createManagedBooking(request.body ?? {}, userId);
      reply.code(201);

      return {
        item,
      };
    } catch (error) {
      reply.code(400);

      return {
        error:
          error instanceof Error ? error.message : "No se pudo crear la reserva.",
      };
    }
  });

  app.patch<{ Params: { bookingId: string }; Body: UpdateBookingInput }>(
    "/:bookingId",
    async (request, reply) => {
      const userId = await requireAuthenticatedUser(request, reply);
      if (!userId) {
        return {
          error: "Inicia sesión para actualizar la cita.",
        };
      }

      try {
        const item = await updateManagedBooking(
          request.params.bookingId,
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
              : "No se pudo actualizar la reserva.",
        };
      }
    },
  );

  app.get<{ Params: { bookingId: string } }>("/:bookingId/policy", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para revisar la política de la cita.",
      };
    }

    try {
      return {
        item: await getBookingPolicy(request.params.bookingId, userId),
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo cargar la politica de la reserva.",
      };
    }
  });

  app.get<{ Params: { bookingId: string } }>("/:bookingId/history", async (request, reply) => {
    const userId = await requireAuthenticatedUser(request, reply);
    if (!userId) {
      return {
        error: "Inicia sesión para ver el historial de la cita.",
      };
    }

    try {
      return {
        items: await getBookingHistory(request.params.bookingId, userId),
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo cargar el historial de la reserva.",
      };
    }
  });
}
