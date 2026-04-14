import { createClient } from "redis";

import { getAppEnv } from "./env.js";
import type { DependencyHealth } from "./database.js";

type RedisClient = ReturnType<typeof createClient>;

let redisClientPromise: Promise<RedisClient> | null = null;

export function isRedisConfigured(): boolean {
  return Boolean(getAppEnv().redisUrl);
}

async function getRedisClient(): Promise<RedisClient> {
  const env = getAppEnv();
  if (!env.redisUrl) {
    throw new Error("REDIS_URL no está configurada.");
  }

  if (!redisClientPromise) {
    const client = createClient({
      url: env.redisUrl,
      socket: {
        reconnectStrategy: false,
      },
    });

    redisClientPromise = client.connect().then(() => client);
  }

  return redisClientPromise;
}

export async function pingRedis(): Promise<DependencyHealth> {
  if (!isRedisConfigured()) {
    return { status: "disabled" };
  }

  try {
    const client = await getRedisClient();
    await client.ping();
    return { status: "up" };
  } catch (error) {
    return {
      status: "down",
      detail: error instanceof Error ? error.message : "No se pudo conectar.",
    };
  }
}

export async function getRedisString(key: string): Promise<string | null> {
  const client = await getRedisClient();
  return client.get(key);
}

export async function setRedisString(
  key: string,
  value: string,
  expiresInSeconds?: number,
): Promise<void> {
  const client = await getRedisClient();
  if (expiresInSeconds && expiresInSeconds > 0) {
    await client.set(key, value, { EX: expiresInSeconds });
    return;
  }

  await client.set(key, value);
}

export async function getRedisTtl(key: string): Promise<number> {
  const client = await getRedisClient();
  return client.ttl(key);
}

export async function deleteRedisKey(key: string): Promise<void> {
  const client = await getRedisClient();
  await client.del(key);
}

export async function closeRedis(): Promise<void> {
  if (!redisClientPromise) {
    return;
  }

  const client = await redisClientPromise;
  redisClientPromise = null;
  await client.quit();
}
