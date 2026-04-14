import { buildServer } from "./app.js";
import { ensurePersistenceReady } from "./infrastructure/migrate.js";
import { ensureStorageReady } from "./infrastructure/storage.js";

async function start() {
  const persistence = await ensurePersistenceReady();
  const app = await buildServer();
  const port = Number(process.env.PORT ?? 4000);
  const host = process.env.HOST ?? "0.0.0.0";

  try {
    app.log.info(persistence, "Persistence layer ready");
    try {
      await ensureStorageReady();
      app.log.info("Storage layer ready");
    } catch (storageError) {
      app.log.warn(storageError, "Storage layer not ready");
    }
    await app.listen({ port, host });
  } catch (error) {
    app.log.error(error);
    process.exit(1);
  }
}

void start();
