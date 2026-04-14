import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { config as loadDotenv } from "dotenv";

loadDotenv({
  path: resolve(dirname(fileURLToPath(import.meta.url)), "../../.env"),
});

function readInt(
  value: string | undefined,
  fallback: number,
  label: string,
): number {
  if (!value || value.trim().length === 0) {
    return fallback;
  }

  const parsed = Number(value);
  if (!Number.isFinite(parsed)) {
    throw new Error(`La variable ${label} no es un número válido.`);
  }

  return parsed;
}

function readBoolean(value: string | undefined, fallback: boolean): boolean {
  if (!value || value.trim().length === 0) {
    return fallback;
  }

  const normalized = value.trim().toLowerCase();
  if (normalized === "true" || normalized === "1" || normalized === "yes") {
    return true;
  }
  if (normalized === "false" || normalized === "0" || normalized === "no") {
    return false;
  }

  return fallback;
}

export interface AppEnv {
  nodeEnv: string;
  host: string;
  port: number;
  databaseUrl: string | null;
  databaseSsl: boolean;
  redisUrl: string | null;
  autoMigrate: boolean;
  authSessionDays: number;
  otpExpiresInSeconds: number;
  otpResendInSeconds: number;
  s3Endpoint: string | null;
  s3Region: string | null;
  s3Bucket: string | null;
  s3AccessKeyId: string | null;
  s3SecretAccessKey: string | null;
}

const appEnv: AppEnv = {
  nodeEnv: process.env.NODE_ENV?.trim() || "development",
  host: process.env.HOST?.trim() || "0.0.0.0",
  port: readInt(process.env.PORT, 4000, "PORT"),
  databaseUrl: process.env.DATABASE_URL?.trim() || null,
  databaseSsl: readBoolean(process.env.DATABASE_SSL, false),
  redisUrl: process.env.REDIS_URL?.trim() || null,
  autoMigrate: readBoolean(process.env.AUTO_MIGRATE, true),
  authSessionDays: readInt(process.env.AUTH_SESSION_DAYS, 30, "AUTH_SESSION_DAYS"),
  otpExpiresInSeconds: readInt(
    process.env.OTP_EXPIRES_IN_SECONDS,
    300,
    "OTP_EXPIRES_IN_SECONDS",
  ),
  otpResendInSeconds: readInt(
    process.env.OTP_RESEND_IN_SECONDS,
    30,
    "OTP_RESEND_IN_SECONDS",
  ),
  s3Endpoint: process.env.S3_ENDPOINT?.trim() || null,
  s3Region: process.env.S3_REGION?.trim() || null,
  s3Bucket: process.env.S3_BUCKET?.trim() || null,
  s3AccessKeyId: process.env.S3_ACCESS_KEY_ID?.trim() || null,
  s3SecretAccessKey: process.env.S3_SECRET_ACCESS_KEY?.trim() || null,
};

export function getAppEnv(): AppEnv {
  return appEnv;
}

export function isStorageConfigured(): boolean {
  return Boolean(
    appEnv.s3Endpoint &&
      appEnv.s3Region &&
      appEnv.s3Bucket &&
      appEnv.s3AccessKeyId &&
      appEnv.s3SecretAccessKey,
  );
}
