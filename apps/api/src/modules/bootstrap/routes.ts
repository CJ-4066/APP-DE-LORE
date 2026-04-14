import type { FastifyInstance } from "fastify";

import {
  getBootstrap,
  getUserIdForAccessToken,
} from "../../data/persistent-store.js";
import { readAccessToken } from "../shared/auth.js";

export async function registerBootstrapRoutes(app: FastifyInstance) {
  app.get("/", async (request) => {
    const accessToken = readAccessToken(request.headers.authorization);
    const userId =
      (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

    return getBootstrap(userId);
  });
}
