import type { FastifyInstance } from "fastify";

import {
  getAdminChatOverview,
  getAdminDashboardSummary,
  getAdminRecentBookings,
  getAdminRecentUsers,
} from "../../data/admin-store.js";
import { requireRole } from "../shared/access.js";

export async function registerAdminRoutes(app: FastifyInstance) {
  app.get("/summary", async (request, reply) => {
    const userId = await requireRole(request, reply, "admin");
    if (!userId) {
      return {
        error:
          reply.statusCode === 403
            ? "No tienes permisos de admin."
            : "Falta el token de acceso.",
      };
    }

    return {
      item: await getAdminDashboardSummary(),
    };
  });

  app.get<{ Querystring: { limit?: string } }>("/bookings", async (request, reply) => {
    const userId = await requireRole(request, reply, "admin");
    if (!userId) {
      return {
        error:
          reply.statusCode === 403
            ? "No tienes permisos de admin."
            : "Falta el token de acceso.",
      };
    }

    return {
      items: await getAdminRecentBookings(Number(request.query.limit ?? "10")),
    };
  });

  app.get<{ Querystring: { limit?: string } }>("/users", async (request, reply) => {
    const userId = await requireRole(request, reply, "admin");
    if (!userId) {
      return {
        error:
          reply.statusCode === 403
            ? "No tienes permisos de admin."
            : "Falta el token de acceso.",
      };
    }

    return {
      items: await getAdminRecentUsers(Number(request.query.limit ?? "10")),
    };
  });

  app.get<{ Querystring: { limit?: string } }>("/chat", async (request, reply) => {
    const userId = await requireRole(request, reply, "admin");
    if (!userId) {
      return {
        error:
          reply.statusCode === 403
            ? "No tienes permisos de admin."
            : "Falta el token de acceso.",
      };
    }

    return {
      item: await getAdminChatOverview(Number(request.query.limit ?? "10")),
    };
  });
}
