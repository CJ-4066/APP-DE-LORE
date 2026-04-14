import type { FastifyInstance } from "fastify";

import { getCourses } from "../../data/mock-store.js";
import { getHomePayload } from "../../data/persistent-store.js";

export async function registerContentRoutes(app: FastifyInstance) {
  app.get("/courses", async () => {
    return {
      items: getCourses(),
    };
  });

  app.get("/daily", async () => {
    const home = await getHomePayload();

    return {
      cardOfTheDay: home.cardOfTheDay,
      astrologicalEnergy: home.astrologicalEnergy,
    };
  });
}
