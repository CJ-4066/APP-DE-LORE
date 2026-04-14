import type { FastifyInstance } from "fastify";

import { getHomePayload } from "../../data/persistent-store.js";

export async function registerHomeRoutes(app: FastifyInstance) {
  app.get("/", async () => {
    return getHomePayload();
  });
}
