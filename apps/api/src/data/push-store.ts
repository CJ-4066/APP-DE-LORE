import { randomUUID } from "node:crypto";

import type { QueryResultRow } from "pg";

import { isDatabaseConfigured, query } from "../infrastructure/database.js";

const demoUserId = "user-mark";

export type PushPlatform = "ios" | "android" | "web";

export interface PushDevice {
  id: string;
  userId: string;
  platform: PushPlatform;
  pushToken: string;
  createdAt: string;
  updatedAt: string;
}

export interface RegisterPushDeviceInput {
  platform?: PushPlatform;
  pushToken?: string;
}

interface PushDeviceRow extends QueryResultRow {
  id: string;
  user_id: string;
  platform: PushPlatform;
  push_token: string;
  created_at: Date | string;
  updated_at: Date | string;
}

const mockDevices = new Map<string, PushDevice>();

function toIsoString(value: Date | string): string {
  if (value instanceof Date) {
    return value.toISOString();
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return String(value);
  }

  return parsed.toISOString();
}

function mapPushDeviceRow(row: PushDeviceRow): PushDevice {
  return {
    id: row.id,
    userId: row.user_id,
    platform: row.platform,
    pushToken: row.push_token,
    createdAt: toIsoString(row.created_at),
    updatedAt: toIsoString(row.updated_at),
  };
}

function validatePushDeviceInput(input: RegisterPushDeviceInput): {
  platform: PushPlatform;
  pushToken: string;
} {
  if (!input.platform || !["ios", "android", "web"].includes(input.platform)) {
    throw new Error("Selecciona una plataforma válida.");
  }

  const pushToken = input.pushToken?.trim() ?? "";
  if (pushToken.length < 8) {
    throw new Error("El token push no es válido.");
  }

  return {
    platform: input.platform,
    pushToken,
  };
}

export async function getPushDevices(userId?: string): Promise<PushDevice[]> {
  const resolvedUserId = userId ?? demoUserId;

  if (!isDatabaseConfigured()) {
    return [...mockDevices.values()]
      .filter((item) => item.userId === resolvedUserId)
      .sort((left, right) => right.updatedAt.localeCompare(left.updatedAt));
  }

  const result = await query<PushDeviceRow>(
    `
      select id, user_id, platform, push_token, created_at, updated_at
      from push_devices
      where user_id = $1
      order by updated_at desc
    `,
    [resolvedUserId],
  );

  return result.rows.map(mapPushDeviceRow);
}

export async function registerPushDevice(
  input: RegisterPushDeviceInput,
  userId?: string,
): Promise<PushDevice> {
  const resolvedUserId = userId ?? demoUserId;
  const { platform, pushToken } = validatePushDeviceInput(input);

  if (!isDatabaseConfigured()) {
    const existing = [...mockDevices.values()].find((item) => item.pushToken === pushToken);
    const device: PushDevice = {
      id: existing?.id ?? randomUUID(),
      userId: resolvedUserId,
      platform,
      pushToken,
      createdAt: existing?.createdAt ?? new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    mockDevices.set(device.id, device);
    return device;
  }

  const result = await query<PushDeviceRow>(
    `
      insert into push_devices (
        id,
        user_id,
        platform,
        push_token,
        updated_at
      ) values ($1, $2, $3, $4, now())
      on conflict (push_token) do update set
        user_id = excluded.user_id,
        platform = excluded.platform,
        updated_at = now()
      returning id, user_id, platform, push_token, created_at, updated_at
    `,
    [randomUUID(), resolvedUserId, platform, pushToken],
  );

  await query(
    `
      update users
      set receives_push = true,
          updated_at = now()
      where id = $1
    `,
    [resolvedUserId],
  );

  return mapPushDeviceRow(result.rows[0]);
}

export async function deletePushDevice(
  deviceId: string,
  userId?: string,
): Promise<void> {
  const resolvedUserId = userId ?? demoUserId;

  if (!isDatabaseConfigured()) {
    const device = mockDevices.get(deviceId);
    if (!device || device.userId !== resolvedUserId) {
      throw new Error("El dispositivo no existe.");
    }

    mockDevices.delete(deviceId);
    return;
  }

  const result = await query(
    `
      delete from push_devices
      where id = $1
        and user_id = $2
    `,
    [deviceId, resolvedUserId],
  );

  if (result.rowCount === 0) {
    throw new Error("El dispositivo no existe.");
  }

  const devices = await getPushDevices(resolvedUserId);
  if (devices.length === 0) {
    await query(
      `
        update users
        set receives_push = false,
            updated_at = now()
        where id = $1
      `,
      [resolvedUserId],
    );
  }
}
