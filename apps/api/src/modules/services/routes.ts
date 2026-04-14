import type { FastifyInstance } from "fastify";

import {
  getProfile,
  getUserIdForAccessToken,
  listServices,
  updateServiceOffer,
  type UpdateServiceOfferInput,
} from "../../data/persistent-store.js";
import { readAccessToken } from "../shared/auth.js";

export async function registerServiceRoutes(app: FastifyInstance) {
  app.get("/", async () => {
    return {
      items: await listServices(),
    };
  });

  app.patch<{ Params: { serviceId: string }; Body: UpdateServiceOfferInput }>(
    "/:serviceId",
    async (request, reply) => {
      try {
        await requireSpecialist(request.headers.authorization);
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

async function requireSpecialist(authorization?: string) {
  const accessToken = readAccessToken(authorization);
  const userId = await getUserIdForAccessToken(accessToken ?? undefined);
  if (!userId) {
    throw new Error(
      "Inicia sesión como especialista para administrar servicios.",
    );
  }

  const user = await getProfile(userId);
  if (user.accountType !== "specialist") {
    throw new Error("Tu perfil debe estar en modo especialista.");
  }
}
