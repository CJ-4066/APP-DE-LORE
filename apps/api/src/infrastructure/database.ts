import pg, { type PoolClient, type QueryResult, type QueryResultRow } from "pg";

import { getAppEnv } from "./env.js";

const { Pool } = pg;

let pool: pg.Pool | null = null;

export interface DependencyHealth {
  status: "disabled" | "up" | "down";
  detail?: string;
}

export function isDatabaseConfigured(): boolean {
  return Boolean(getAppEnv().databaseUrl);
}

export function getPool(): pg.Pool {
  const env = getAppEnv();
  if (!env.databaseUrl) {
    throw new Error("DATABASE_URL no está configurada.");
  }

  if (!pool) {
    pool = new Pool({
      connectionString: env.databaseUrl,
      ssl: env.databaseSsl ? { rejectUnauthorized: false } : undefined,
    });
  }

  return pool;
}

export async function query<T extends QueryResultRow>(
  text: string,
  params: unknown[] = [],
): Promise<QueryResult<T>> {
  return getPool().query<T>(text, params);
}

export async function withTransaction<T>(
  work: (client: PoolClient) => Promise<T>,
): Promise<T> {
  const client = await getPool().connect();

  try {
    await client.query("BEGIN");
    const result = await work(client);
    await client.query("COMMIT");
    return result;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function pingDatabase(): Promise<DependencyHealth> {
  if (!isDatabaseConfigured()) {
    return { status: "disabled" };
  }

  try {
    await query("select 1");
    return { status: "up" };
  } catch (error) {
    return {
      status: "down",
      detail: error instanceof Error ? error.message : "No se pudo conectar.",
    };
  }
}

export async function closeDatabase(): Promise<void> {
  if (pool) {
    await pool.end();
    pool = null;
  }
}
