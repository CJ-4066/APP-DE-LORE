import Fastify from "fastify";
import cors from "@fastify/cors";

import { pingDatabase } from "./infrastructure/database.js";
import { pingRedis } from "./infrastructure/redis.js";
import { pingStorage } from "./infrastructure/storage.js";
import { registerAdminRoutes } from "./modules/admin/routes.js";
import { registerAstroRoutes } from "./modules/astro/routes.js";
import { registerAuthRoutes } from "./modules/auth/routes.js";
import { registerBookingRoutes } from "./modules/bookings/routes.js";
import { registerBootstrapRoutes } from "./modules/bootstrap/routes.js";
import { registerChatRoutes } from "./modules/chat/routes.js";
import { registerContentRoutes } from "./modules/content/routes.js";
import { registerHomeRoutes } from "./modules/home/routes.js";
import { registerNumerologyRoutes } from "./modules/numerology/routes.js";
import { registerPaymentRoutes } from "./modules/payments/routes.js";
import { registerPlaceRoutes } from "./modules/places/routes.js";
import { registerPlanRoutes } from "./modules/plans/routes.js";
import { registerProfileRoutes } from "./modules/profile/routes.js";
import { registerPushRoutes } from "./modules/push/routes.js";
import { registerServiceRoutes } from "./modules/services/routes.js";
import { registerShopRoutes } from "./modules/shop/routes.js";
import { registerSpecialistRoutes } from "./modules/specialists/routes.js";
import { registerStorageRoutes } from "./modules/storage/routes.js";
import { registerSubscriptionRoutes } from "./modules/subscriptions/routes.js";
import { registerTarotRoutes } from "./modules/tarot/routes.js";

export async function buildServer() {
  const app = Fastify({
    logger: true,
    bodyLimit: 10 * 1024 * 1024,
  });

  await app.register(cors, {
    origin: true,
  });

  app.addContentTypeParser(
    /^image\/.*/,
    { parseAs: "buffer" },
    (_request, body, done) => {
      done(null, body);
    },
  );
  app.addContentTypeParser(
    "application/octet-stream",
    { parseAs: "buffer" },
    (_request, body, done) => {
      done(null, body);
    },
  );

  app.get("/health", async () => {
    const [database, redis, storage] = await Promise.all([
      pingDatabase(),
      pingRedis(),
      pingStorage(),
    ]);
    const status =
      database.status === "down" ||
      redis.status === "down" ||
      storage.status === "down"
        ? "degraded"
        : "ok";

    return {
      status,
      service: "lo-renaciente-api",
      timestamp: new Date().toISOString(),
      dependencies: {
        database,
        redis,
        storage,
      },
    };
  });

  await app.register(registerAuthRoutes, { prefix: "/api/auth" });
  await app.register(registerAstroRoutes, { prefix: "/api/astro" });
  await app.register(registerNumerologyRoutes, { prefix: "/api/numerology" });
  await app.register(registerPlaceRoutes, { prefix: "/api/places" });
  await app.register(registerBootstrapRoutes, { prefix: "/api/bootstrap" });
  await app.register(registerProfileRoutes, { prefix: "/api/profile" });
  await app.register(registerBookingRoutes, { prefix: "/api/bookings" });
  await app.register(registerChatRoutes, { prefix: "/api/chat" });
  await app.register(registerHomeRoutes, { prefix: "/api/home" });
  await app.register(registerPlanRoutes, { prefix: "/api/plans" });
  await app.register(registerServiceRoutes, { prefix: "/api/services" });
  await app.register(registerShopRoutes, { prefix: "/api/shop" });
  await app.register(registerContentRoutes, { prefix: "/api/content" });
  await app.register(registerTarotRoutes, { prefix: "/api/tarot" });
  await app.register(registerSpecialistRoutes, { prefix: "/api/specialists" });
  await app.register(registerSubscriptionRoutes, {
    prefix: "/api/subscriptions",
  });
  await app.register(registerPushRoutes, { prefix: "/api/push" });
  await app.register(registerStorageRoutes, { prefix: "/api/storage" });
  await app.register(registerPaymentRoutes, { prefix: "/api/payments" });
  await app.register(registerAdminRoutes, { prefix: "/api/admin" });

  return app;
}
