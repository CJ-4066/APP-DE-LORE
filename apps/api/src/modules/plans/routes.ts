import type { FastifyInstance } from "fastify";

import { getPlans } from "../../data/mock-store.js";

export async function registerPlanRoutes(app: FastifyInstance) {
  app.get("/", async () => {
    return {
      items: getPlans(),
    };
  });
}
