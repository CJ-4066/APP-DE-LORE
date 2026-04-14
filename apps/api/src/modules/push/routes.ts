import type { FastifyInstance } from "fastify";

import {
  deletePushDevice,
  getPushDevices,
  registerPushDevice,
  type RegisterPushDeviceInput,
} from "../../data/push-store.js";
import { getUserIdForAccessToken } from "../../data/persistent-store.js";
import { readAccessToken } from "../shared/auth.js";

export async function registerPushRoutes(app: FastifyInstance) {
  app.get("/devices", async (request) => {
    const accessToken = readAccessToken(request.headers.authorization);
    const userId =
      (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

    return {
      items: await getPushDevices(userId),
    };
  });

  app.post<{ Body: RegisterPushDeviceInput }>("/devices", async (request, reply) => {
    try {
      const accessToken = readAccessToken(request.headers.authorization);
      const userId =
        (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

      reply.code(201);
      return {
        item: await registerPushDevice(request.body ?? {}, userId),
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo registrar el dispositivo.",
      };
    }
  });

  app.delete<{ Params: { deviceId: string } }>("/devices/:deviceId", async (request, reply) => {
    try {
      const accessToken = readAccessToken(request.headers.authorization);
      const userId =
        (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

      await deletePushDevice(request.params.deviceId, userId);
      reply.code(204);
      return null;
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo eliminar el dispositivo.",
      };
    }
  });
}
