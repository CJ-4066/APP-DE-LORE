import type { FastifyInstance } from "fastify";

import {
  completePhoneProfile,
  getPhoneAuthSession,
  getUserIdForAccessToken,
  revokePhoneAuthSession,
  type CompletePhoneProfileInput,
  type PhoneAuthStartInput,
  type PhoneAuthVerifyInput,
  startPhoneAuth,
  verifyPhoneAuth,
} from "../../data/persistent-store.js";
import { readAccessToken } from "../shared/auth.js";

export async function registerAuthRoutes(app: FastifyInstance) {
  app.post<{ Body: PhoneAuthStartInput }>("/phone/start", async (request, reply) => {
    try {
      const item = await startPhoneAuth(request.body ?? {});
      reply.code(200);

      return { item };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error ? error.message : "No se pudo enviar el código.",
      };
    }
  });

  app.post<{ Body: PhoneAuthVerifyInput }>("/phone/verify", async (request, reply) => {
    try {
      const item = await verifyPhoneAuth(request.body ?? {});
      reply.code(200);

      return { item };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error ? error.message : "No se pudo verificar el código.",
      };
    }
  });

  app.get("/me", async (request, reply) => {
    const accessToken = readAccessToken(request.headers.authorization);
    if (!accessToken) {
      reply.code(401);
      return { error: "Falta el token de acceso." };
    }

    try {
      const userId = await getUserIdForAccessToken(accessToken);
      if (!userId) {
        reply.code(401);
        return { error: "La sesión ya no es válida. Solicita un nuevo código." };
      }

      return {
        item: await getPhoneAuthSession(accessToken),
      };
    } catch (error) {
      reply.code(401);
      return {
        error:
          error instanceof Error ? error.message : "No se pudo validar la sesión.",
      };
    }
  });

  app.patch<{ Body: CompletePhoneProfileInput }>(
    "/profile",
    async (request, reply) => {
      const accessToken = readAccessToken(request.headers.authorization);
      if (!accessToken) {
        reply.code(401);
        return { error: "Falta el token de acceso." };
      }

      try {
        const item = await completePhoneProfile(accessToken, request.body ?? {});
        reply.code(200);

        return { item };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo completar el perfil.",
        };
      }
    },
  );

  app.post("/logout", async (request, reply) => {
    const accessToken = readAccessToken(request.headers.authorization);
    if (!accessToken) {
      reply.code(401);
      return { error: "Falta el token de acceso." };
    }

    await revokePhoneAuthSession(accessToken);
    reply.code(200);
    return { ok: true };
  });
}
