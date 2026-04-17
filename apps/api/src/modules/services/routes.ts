import type { FastifyInstance } from "fastify";

import {
  listServices,
  updateServiceOffer,
  type UpdateServiceOfferInput,
} from "../../data/persistent-store.js";
import { requireManagedSpecialistProfile } from "../shared/access.js";

export async function registerServiceRoutes(app: FastifyInstance) {
  app.get("/", async () => {
    return {
      items: await listServices(),
    };
  });

  app.patch<{ Params: { serviceId: string }; Body: UpdateServiceOfferInput }>(
    "/:serviceId",
    async (request, reply) => {
      const access = await requireManagedSpecialistProfile(request, reply);
      if (!access) {
        return {
          error:
            reply.statusCode === 403
              ? "Configura tu perfil especialista para administrar tus servicios."
              : "Inicia sesión como especialista para administrar servicios.",
        };
      }

      try {
        const services = await listServices();
        const service = services.find((item) => item.id === request.params.serviceId);
        if (!service || !service.specialistIds.includes(access.specialistProfileId)) {
          reply.code(403);
          return {
            error: "Solo puedes editar servicios que pertenezcan a tu perfil especialista.",
          };
        }

        return {
          item: await updateServiceOffer(
            request.params.serviceId,
            request.body ?? {},
          ),
        };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo actualizar el servicio.",
        };
      }
    },
  );
}
