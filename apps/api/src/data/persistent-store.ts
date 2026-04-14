import { randomUUID } from "node:crypto";

import type { PoolClient, QueryResult, QueryResultRow } from "pg";

import {
  getCurrentSubscription as getCurrentSubscriptionBilling,
  getPaymentsConfig as getPaymentsConfigBilling,
} from "./billing-store.js";
import {
  isDatabaseConfigured,
  query,
  withTransaction,
} from "../infrastructure/database.js";
import { getAppEnv } from "../infrastructure/env.js";
import {
  getRedisTtl,
  isRedisConfigured,
  setRedisString,
} from "../infrastructure/redis.js";
import { buildDailyHomeContent } from "./home-daily.js";
import {
  completePhoneProfile as completePhoneProfileMock,
  createBooking as createBookingMock,
  createShopProduct as createShopProductMock,
  createShopOrder as createShopOrderMock,
  getAdminSummary,
  getBootstrap as getBootstrapMock,
  getBookings as getBookingsMock,
  getCourses,
  getHomePayload as getHomePayloadMock,
  getPhoneAuthSession as getPhoneAuthSessionMock,
  getPlans,
  getProfile as getProfileMock,
  revokePhoneAuthSession as revokePhoneAuthSessionMock,
  getServices,
  getShopData as getShopDataMock,
  getShopOrders as getShopOrdersMock,
  getSpecialists,
  getUserIdForAccessToken as getUserIdForAccessTokenMock,
  startPhoneAuth as startPhoneAuthMock,
  updateServiceOffer as updateServiceOfferMock,
  type AccountType,
  type AppBootstrap,
  type Booking,
  type BookingStatus,
  type CompletePhoneProfileInput,
  type CreateShopProductInput,
  type CreateShopOrderInput,
  type CreateBookingInput,
  type HomePayload,
  type Money,
  type PhoneAuthSessionPayload,
  type PhoneAuthStartInput,
  type PhoneAuthStartResult,
  type PhoneAuthVerifyInput,
  type ServiceOffer,
  type SessionMode,
  type ShopData,
  type ShopOrder,
  type ShopOrderItem,
  type ShopOrderStatus,
  type ShopProduct,
  type Subscription,
  type UpdateBookingInput,
  type UpdateShopOrderStatusInput,
  type UpdateShopProductInput,
  type UpdateServiceOfferInput,
  type UpdateUserProfileInput,
  type UserProfile,
  updateBooking as updateBookingMock,
  updateCurrentUser as updateCurrentUserMock,
  updateShopOrderStatus as updateShopOrderStatusMock,
  updateShopProduct as updateShopProductMock,
  verifyPhoneAuth as verifyPhoneAuthMock,
} from "./mock-store.js";
export type {
  CompletePhoneProfileInput,
  CreateShopProductInput,
  CreateShopOrderInput,
  CreateBookingInput,
  PhoneAuthStartInput,
  PhoneAuthVerifyInput,
  UpdateBookingInput,
  UpdateShopOrderStatusInput,
  UpdateShopProductInput,
  UpdateServiceOfferInput,
  UpdateUserProfileInput,
} from "./mock-store.js";

const demoUserId = "user-mark";

const quickActions: HomePayload["quickActions"] = [
  {
    id: "quick-numerology",
    label: "Numerología",
    description: "Perfil, ciclos y nombre natal",
    type: "content",
  },
  {
    id: "quick-premium",
    label: "Ver Premium",
    description: "Plan, beneficios y estado actual",
    type: "subscription",
  },
  {
    id: "quick-profile",
    label: "Completar perfil astral",
    description: "Fecha, hora y lugar de nacimiento",
    type: "profile",
  },
];

interface UserRow extends QueryResultRow {
  id: string;
  first_name: string;
  last_name: string;
  nickname: string;
  email: string;
  avatar_url: string;
  location: string;
  timezone: string;
  zodiac_sign: string;
  plan_id: string;
  account_type: AccountType;
  subject_name: string;
  birth_date: string;
  birth_time: string;
  birth_time_unknown: boolean;
  city: string;
  state: string;
  country: string;
  time_zone_id: string;
  utc_offset: string;
  latitude: number | null;
  longitude: number | null;
  focus_areas: unknown;
  preferred_session_modes: unknown;
  receives_push: boolean;
}

interface IdentityRow extends QueryResultRow {
  phone_number: string;
  user_id: string;
  country_code: string;
  dial_code: string;
  profile_completed: boolean;
}

interface VerificationRow extends QueryResultRow {
  phone_number: string;
  code: string;
  country_code: string;
  dial_code: string;
  expires_at: Date | string;
  attempts_remaining: number;
}

interface SessionRow extends QueryResultRow {
  access_token: string;
  refresh_token: string;
  user_id: string;
  phone_number: string;
  expires_at: Date | string;
}

interface BookingRow extends QueryResultRow {
  id: string;
  user_id: string;
  service_id: string;
  service_name: string;
  specialist_id: string;
  specialist_name: string;
  scheduled_at: Date | string;
  mode: SessionMode;
  status: BookingStatus;
  price_amount: string | number;
  price_currency: string;
  notes: string;
}

interface ServiceOfferOverrideRow extends QueryResultRow {
  service_id: string;
  price_amount: string | number;
  price_currency: string;
  duration_minutes: number;
}

interface ShopProductOverrideRow extends QueryResultRow {
  product_id: string;
  name: string;
  category: string;
  short_description: string;
  description: string;
  price_amount: string | number;
  price_currency: string;
  image_url: string;
  artwork: string;
  badge: string;
  featured: boolean;
  stock_label: string;
  tags: unknown;
  created_at: Date | string;
  updated_at: Date | string;
}

interface ShopOrderRow extends QueryResultRow {
  id: string;
  user_id: string;
  order_code: string;
  status: ShopOrderStatus;
  created_at: Date | string;
  delivery_address: string;
  notes: string;
  subtotal_amount: string | number;
  subtotal_currency: string;
  shipping_amount: string | number;
  shipping_currency: string;
  total_amount: string | number;
  total_currency: string;
  item_count: number;
}

interface ShopOrderItemRow extends QueryResultRow {
  order_id: string;
  product_id: string;
  product_name: string;
  category: string;
  quantity: number;
  image_url: string;
  unit_price_amount: string | number;
  unit_price_currency: string;
  line_total_amount: string | number;
  line_total_currency: string;
}

type QueryRunner = Pick<PoolClient, "query">;

async function runQuery<T extends QueryResultRow>(
  sql: string,
  params: unknown[] = [],
  runner?: QueryRunner,
): Promise<QueryResult<T>> {
  if (runner) {
    return runner.query<T>(sql, params);
  }

  return query<T>(sql, params);
}

function normalizeDialCode(value?: string): string {
  const digits = (value ?? "").replace(/\D/g, "");
  if (digits.length < 1 || digits.length > 4) {
    throw new Error("Selecciona un prefijo internacional válido.");
  }

  return `+${digits}`;
}

function normalizeNationalNumber(value?: string): string {
  const digits = (value ?? "").replace(/\D/g, "");
  if (digits.length < 6 || digits.length > 12) {
    throw new Error("Ingresa un número de teléfono válido.");
  }

  return digits;
}

function normalizeFullPhoneNumber(value?: string): string {
  const digits = (value ?? "").replace(/\D/g, "");
  if (digits.length < 8 || digits.length > 15) {
    throw new Error("El número de teléfono no es válido.");
  }

  return `+${digits}`;
}

function normalizeBirthDateInput(value?: string): string {
  const raw = (value ?? "").trim();
  const isoMatch = raw.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (isoMatch) {
    return raw;
  }

  const dayFirstMatch = raw.match(/^(\d{2})-(\d{2})-(\d{4})$/);
  if (dayFirstMatch) {
    return `${dayFirstMatch[3]}-${dayFirstMatch[2]}-${dayFirstMatch[1]}`;
  }

  return raw;
}

function inferZodiacSign(birthDate?: string): string {
  const normalizedBirthDate = normalizeBirthDateInput(birthDate);
  const match = normalizedBirthDate.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!match) {
    return "";
  }

  const month = Number(match[2]);
  const day = Number(match[3]);

  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return "Aries";
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return "Tauro";
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20))
    return "Geminis";
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return "Cancer";
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return "Leo";
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return "Virgo";
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return "Libra";
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21))
    return "Escorpio";
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) {
    return "Sagitario";
  }
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) {
    return "Capricornio";
  }
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18))
    return "Acuario";
  if ((month === 2 && day >= 19) || (month === 3 && day <= 20)) return "Piscis";

  return "";
}

function generateMockOtpCode(): string {
  return String(Math.floor(100000 + Math.random() * 900000));
}

function readStringArray(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value.filter((item): item is string => typeof item === "string");
  }

  return [];
}

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

function mapUserRow(row: UserRow): UserProfile {
  return {
    id: row.id,
    firstName: row.first_name,
    lastName: row.last_name,
    nickname: row.nickname,
    email: row.email,
    avatarUrl: row.avatar_url,
    location: row.location,
    timezone: row.timezone,
    zodiacSign: row.zodiac_sign,
    planId: row.plan_id,
    accountType: row.account_type,
    natalChart: {
      subjectName: row.subject_name,
      birthDate: row.birth_date,
      birthTime: row.birth_time,
      birthTimeUnknown: row.birth_time_unknown,
      city: row.city,
      state: row.state,
      country: row.country,
      timeZoneId: row.time_zone_id,
      utcOffset: row.utc_offset,
      latitude: row.latitude,
      longitude: row.longitude,
    },
    preferences: {
      focusAreas: readStringArray(row.focus_areas),
      preferredSessionModes: readStringArray(
        row.preferred_session_modes,
      ) as SessionMode[],
      receivesPush: row.receives_push,
    },
  };
}

function mapBookingRow(row: BookingRow): Booking {
  return {
    id: row.id,
    userId: row.user_id,
    serviceId: row.service_id,
    serviceName: row.service_name,
    specialistId: row.specialist_id,
    specialistName: row.specialist_name,
    scheduledAt: toIsoString(row.scheduled_at),
    mode: row.mode,
    status: row.status,
    price: {
      amount: Number(row.price_amount),
      currency: row.price_currency,
    },
    notes: row.notes,
  };
}

function mapMoney(amount: string | number, currency: string): Money {
  return {
    amount: Number(amount),
    currency: currency.trim() || "USD",
  };
}

function cloneMoney(value: Money): Money {
  return {
    amount: value.amount,
    currency: value.currency,
  };
}

function cloneShopProduct(product: ShopProduct): ShopProduct {
  return {
    ...product,
    price: cloneMoney(product.price),
    tags: [...product.tags],
  };
}

function mapServiceWithOverride(
  service: ServiceOffer,
  override?: ServiceOfferOverrideRow,
): ServiceOffer {
  if (!override) {
    return {
      ...service,
      price: cloneMoney(service.price),
      deliveryModes: [...service.deliveryModes],
      specialistIds: [...service.specialistIds],
    };
  }

  return {
    ...service,
    durationMinutes: Number(override.duration_minutes),
    price: mapMoney(override.price_amount, override.price_currency),
    deliveryModes: [...service.deliveryModes],
    specialistIds: [...service.specialistIds],
  };
}

function mapShopProductOverrideRow(row: ShopProductOverrideRow): ShopProduct {
  return {
    id: row.product_id,
    name: row.name,
    category: row.category,
    shortDescription: row.short_description,
    description: row.description,
    price: mapMoney(row.price_amount, row.price_currency),
    imageUrl: row.image_url,
    artwork: row.artwork,
    badge: row.badge,
    featured: row.featured,
    stockLabel: row.stock_label,
    tags: readStringArray(row.tags),
  };
}

function mapShopOrderRows(
  order: ShopOrderRow,
  items: ShopOrderItemRow[],
): ShopOrder {
  return {
    id: order.id,
    userId: order.user_id,
    orderCode: order.order_code,
    status: order.status,
    createdAt: toIsoString(order.created_at),
    deliveryAddress: order.delivery_address,
    notes: order.notes,
    subtotal: mapMoney(order.subtotal_amount, order.subtotal_currency),
    shipping: mapMoney(order.shipping_amount, order.shipping_currency),
    total: mapMoney(order.total_amount, order.total_currency),
    itemCount: Number(order.item_count),
    items: items.map((item) => ({
      productId: item.product_id,
      productName: item.product_name,
      category: item.category,
      quantity: Number(item.quantity),
      imageUrl: item.image_url,
      unitPrice: mapMoney(item.unit_price_amount, item.unit_price_currency),
      lineTotal: mapMoney(item.line_total_amount, item.line_total_currency),
    })),
  };
}

function buildOrderCode(orderCount: number): string {
  const year = new Date().getFullYear();
  return `LR-${year}-${String(orderCount + 41).padStart(3, "0")}`;
}

function slugifyShopValue(value: string): string {
  return (
    value
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .slice(0, 48) || "producto"
  );
}

function inferShopArtwork(category: string): string {
  const normalized = category.toLowerCase();
  if (normalized.includes("vela")) {
    return "candle-moon";
  }
  if (normalized.includes("cuadro") || normalized.includes("carta")) {
    return "natal-gold";
  }
  if (normalized.includes("estatua") || normalized.includes("figura")) {
    return "statue-moon";
  }
  if (normalized.includes("simbolo") || normalized.includes("símbolo")) {
    return "symbol-flower";
  }
  if (normalized.includes("tarot") || normalized.includes("mazo")) {
    return "tarot-rider";
  }

  return "shop-default";
}

function normalizeShopTags(tags?: string[]): string[] {
  const normalized = (tags ?? [])
    .map((tag) => tag.trim())
    .filter((tag) => tag.length > 0);

  return normalized.length > 0 ? normalized.slice(0, 6) : ["nuevo"];
}

function isShopOrderStatus(value: unknown): value is ShopOrderStatus {
  return (
    value === "pending" ||
    value === "confirmed" ||
    value === "preparing" ||
    value === "shipped"
  );
}

function buildDefaultUser(): UserProfile {
  return {
    id: randomUUID(),
    firstName: "",
    lastName: "",
    nickname: "",
    email: "",
    avatarUrl: "",
    location: "",
    timezone: "America/Lima",
    zodiacSign: "",
    planId: "free",
    accountType: "client",
    natalChart: {
      subjectName: "",
      birthDate: "",
      birthTime: "",
      birthTimeUnknown: true,
      city: "",
      state: "",
      country: "",
      timeZoneId: "",
      utcOffset: "",
      latitude: null,
      longitude: null,
    },
    preferences: {
      focusAreas: [],
      preferredSessionModes: ["chat"],
      receivesPush: true,
    },
  };
}

function mergeUserProfile(
  existingUser: UserProfile,
  input: UpdateUserProfileInput,
): UserProfile {
  const nextBirthDate = normalizeBirthDateInput(
    input.natalChart?.birthDate ?? existingUser.natalChart.birthDate,
  );
  const normalizedNatalChart = input.natalChart
    ? {
        ...input.natalChart,
        birthDate: normalizeBirthDateInput(input.natalChart.birthDate),
      }
    : undefined;
  const requestedZodiacSign = input.zodiacSign?.trim();

  return {
    ...existingUser,
    firstName: input.firstName ?? existingUser.firstName,
    lastName: input.lastName ?? existingUser.lastName,
    nickname: input.nickname ?? existingUser.nickname,
    email: input.email ?? existingUser.email,
    avatarUrl: input.avatarUrl ?? existingUser.avatarUrl,
    location: input.location ?? existingUser.location,
    accountType: input.accountType ?? existingUser.accountType,
    timezone: input.natalChart?.timeZoneId?.trim() || existingUser.timezone,
    zodiacSign:
      requestedZodiacSign == null
        ? existingUser.zodiacSign
        : requestedZodiacSign.length === 0
          ? inferZodiacSign(nextBirthDate)
          : requestedZodiacSign,
    natalChart: {
      ...existingUser.natalChart,
      ...(normalizedNatalChart ?? {}),
    },
    preferences: {
      ...existingUser.preferences,
      ...(input.preferences ?? {}),
      preferredSessionModes:
        input.preferences?.preferredSessionModes ??
        existingUser.preferences.preferredSessionModes,
      focusAreas:
        input.preferences?.focusAreas ?? existingUser.preferences.focusAreas,
      receivesPush:
        input.preferences?.receivesPush ??
        existingUser.preferences.receivesPush,
    },
  };
}

function isProfileCompleted(user: UserProfile): boolean {
  return Boolean(
    user.firstName.trim() &&
    user.lastName.trim() &&
    user.natalChart.birthDate.trim() &&
    user.natalChart.city.trim() &&
    user.natalChart.country.trim() &&
    user.natalChart.timeZoneId.trim() &&
    user.natalChart.utcOffset.trim() &&
    user.natalChart.latitude !== null &&
    user.natalChart.longitude !== null,
  );
}

async function findUserById(
  userId: string,
  runner?: QueryRunner,
): Promise<UserProfile | null> {
  const result = await runQuery<UserRow>(
    `
      select
        id,
        first_name,
        last_name,
        nickname,
        email,
        avatar_url,
        location,
        timezone,
        zodiac_sign,
        plan_id,
        account_type,
        subject_name,
        birth_date,
        birth_time,
        birth_time_unknown,
        city,
        state,
        country,
        time_zone_id,
        utc_offset,
        latitude,
        longitude,
        focus_areas,
        preferred_session_modes,
        receives_push
      from users
      where id = $1
    `,
    [userId],
    runner,
  );

  return result.rows[0] ? mapUserRow(result.rows[0]) : null;
}

async function findIdentityByPhone(
  phoneNumber: string,
  runner?: QueryRunner,
): Promise<IdentityRow | null> {
  const result = await runQuery<IdentityRow>(
    `
      select phone_number, user_id, country_code, dial_code, profile_completed
      from phone_auth_identities
      where phone_number = $1
    `,
    [phoneNumber],
    runner,
  );

  return result.rows[0] ?? null;
}

async function findSessionByAccessToken(
  accessToken: string,
  runner?: QueryRunner,
): Promise<SessionRow | null> {
  const result = await runQuery<SessionRow>(
    `
      select access_token, refresh_token, user_id, phone_number, expires_at
      from auth_sessions
      where access_token = $1
    `,
    [accessToken],
    runner,
  );

  return result.rows[0] ?? null;
}

async function upsertUserProfile(
  user: UserProfile,
  runner?: QueryRunner,
): Promise<void> {
  await runQuery(
    `
      insert into users (
        id,
        first_name,
        last_name,
        nickname,
        email,
        avatar_url,
        location,
        timezone,
        zodiac_sign,
        plan_id,
        account_type,
        subject_name,
        birth_date,
        birth_time,
        birth_time_unknown,
        city,
        state,
        country,
        time_zone_id,
        utc_offset,
        latitude,
        longitude,
        focus_areas,
        preferred_session_modes,
        receives_push,
        updated_at
      ) values (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14,
        $15, $16, $17, $18, $19, $20, $21, $22, $23::jsonb, $24::jsonb, $25, now()
      )
      on conflict (id) do update set
        first_name = excluded.first_name,
        last_name = excluded.last_name,
        nickname = excluded.nickname,
        email = excluded.email,
        avatar_url = excluded.avatar_url,
        location = excluded.location,
        timezone = excluded.timezone,
        zodiac_sign = excluded.zodiac_sign,
        plan_id = excluded.plan_id,
        account_type = excluded.account_type,
        subject_name = excluded.subject_name,
        birth_date = excluded.birth_date,
        birth_time = excluded.birth_time,
        birth_time_unknown = excluded.birth_time_unknown,
        city = excluded.city,
        state = excluded.state,
        country = excluded.country,
        time_zone_id = excluded.time_zone_id,
        utc_offset = excluded.utc_offset,
        latitude = excluded.latitude,
        longitude = excluded.longitude,
        focus_areas = excluded.focus_areas,
        preferred_session_modes = excluded.preferred_session_modes,
        receives_push = excluded.receives_push,
        updated_at = now()
    `,
    [
      user.id,
      user.firstName,
      user.lastName,
      user.nickname,
      user.email,
      user.avatarUrl,
      user.location,
      user.timezone,
      user.zodiacSign,
      user.planId,
      user.accountType,
      user.natalChart.subjectName,
      user.natalChart.birthDate,
      user.natalChart.birthTime,
      user.natalChart.birthTimeUnknown,
      user.natalChart.city,
      user.natalChart.state,
      user.natalChart.country,
      user.natalChart.timeZoneId,
      user.natalChart.utcOffset,
      user.natalChart.latitude,
      user.natalChart.longitude,
      JSON.stringify(user.preferences.focusAreas),
      JSON.stringify(user.preferences.preferredSessionModes),
      user.preferences.receivesPush,
    ],
    runner,
  );
}

async function setPhoneIdentity(
  input: {
    phoneNumber: string;
    userId: string;
    countryCode: string;
    dialCode: string;
    profileCompleted: boolean;
  },
  runner?: QueryRunner,
): Promise<void> {
  await runQuery(
    `
      insert into phone_auth_identities (
        phone_number,
        user_id,
        country_code,
        dial_code,
        profile_completed,
        updated_at
      ) values ($1, $2, $3, $4, $5, now())
      on conflict (phone_number) do update set
        user_id = excluded.user_id,
        country_code = excluded.country_code,
        dial_code = excluded.dial_code,
        profile_completed = excluded.profile_completed,
        updated_at = now()
    `,
    [
      input.phoneNumber,
      input.userId,
      input.countryCode,
      input.dialCode,
      input.profileCompleted,
    ],
    runner,
  );
}

async function buildPhoneAuthSessionPayloadFromSession(
  session: SessionRow,
  runner?: QueryRunner,
): Promise<PhoneAuthSessionPayload> {
  const user = await findUserById(session.user_id, runner);
  const identity = await findIdentityByPhone(session.phone_number, runner);

  if (!user || !identity) {
    throw new Error("No se encontró la sesión del teléfono autenticado.");
  }

  return {
    accessToken: session.access_token,
    refreshToken: session.refresh_token,
    phoneNumber: session.phone_number,
    profileCompleted: identity.profile_completed,
    user,
  };
}

async function readServiceOfferOverrides(
  runner?: QueryRunner,
): Promise<Map<string, ServiceOfferOverrideRow>> {
  const result = await runQuery<ServiceOfferOverrideRow>(
    `
      select
        service_id,
        price_amount,
        price_currency,
        duration_minutes
      from service_offer_overrides
    `,
    [],
    runner,
  );

  return new Map(result.rows.map((row) => [row.service_id, row]));
}

async function listDatabaseServices(
  runner?: QueryRunner,
): Promise<ServiceOffer[]> {
  const overrides = await readServiceOfferOverrides(runner);

  return getServices().map((service) =>
    mapServiceWithOverride(service, overrides.get(service.id)),
  );
}

async function getServiceById(
  serviceId: string,
  runner?: QueryRunner,
): Promise<ServiceOffer | null> {
  return (
    (await listDatabaseServices(runner)).find(
      (item) => item.id === serviceId,
    ) ?? null
  );
}

function getSpecialistById(specialistId: string) {
  return getSpecialists().find((item) => item.id === specialistId) ?? null;
}

async function getDatabaseUser(
  userId?: string,
  runner?: QueryRunner,
): Promise<UserProfile> {
  const resolvedUserId = userId ?? demoUserId;
  const user = await findUserById(resolvedUserId, runner);
  if (!user) {
    throw new Error("El usuario solicitado no existe.");
  }

  return user;
}

export async function getUserIdForAccessToken(
  accessToken?: string,
): Promise<string | null> {
  if (!isDatabaseConfigured()) {
    return getUserIdForAccessTokenMock(accessToken);
  }

  if (!accessToken) {
    return null;
  }

  const result = await runQuery<{ user_id: string }>(
    `
      select user_id
      from auth_sessions
      where access_token = $1
        and expires_at > now()
    `,
    [accessToken],
  );

  if (result.rows[0]) {
    return result.rows[0].user_id;
  }

  await runQuery("delete from auth_sessions where access_token = $1", [
    accessToken,
  ]);
  return null;
}

export async function getPhoneAuthSession(
  accessToken: string,
): Promise<PhoneAuthSessionPayload> {
  if (!isDatabaseConfigured()) {
    return getPhoneAuthSessionMock(accessToken);
  }

  const session = await findSessionByAccessToken(accessToken);

  if (!session || new Date(session.expires_at).getTime() <= Date.now()) {
    await runQuery("delete from auth_sessions where access_token = $1", [
      accessToken,
    ]);
    throw new Error("La sesión ya no es válida. Solicita un nuevo código.");
  }

  return buildPhoneAuthSessionPayloadFromSession(session);
}

export async function revokePhoneAuthSession(
  accessToken: string,
): Promise<void> {
  if (!isDatabaseConfigured()) {
    return revokePhoneAuthSessionMock(accessToken);
  }

  await runQuery("delete from auth_sessions where access_token = $1", [
    accessToken,
  ]);
}

export async function startPhoneAuth(
  input: PhoneAuthStartInput,
): Promise<PhoneAuthStartResult> {
  if (!isDatabaseConfigured()) {
    return startPhoneAuthMock(input);
  }

  const countryCode = (input.countryCode ?? "").trim().toUpperCase();
  const dialCode = normalizeDialCode(input.dialCode);
  const nationalNumber = normalizeNationalNumber(input.nationalNumber);
  const phoneNumber = `${dialCode}${nationalNumber}`;
  const debugCode = generateMockOtpCode();
  const env = getAppEnv();
  const cooldownKey = `auth:otp:cooldown:${phoneNumber}`;

  if (isRedisConfigured()) {
    try {
      const ttl = await getRedisTtl(cooldownKey);
      if (ttl > 0) {
        throw new Error(
          `Espera ${ttl} segundos antes de solicitar otro código.`,
        );
      }
    } catch (error) {
      if (error instanceof Error && error.message.startsWith("Espera ")) {
        throw error;
      }
    }
  }

  await runQuery(
    `
      insert into phone_verification_codes (
        phone_number,
        code,
        country_code,
        dial_code,
        expires_at,
        attempts_remaining,
        created_at
      ) values (
        $1,
        $2,
        $3,
        $4,
        now() + make_interval(secs => $5::int),
        3,
        now()
      )
      on conflict (phone_number) do update set
        code = excluded.code,
        country_code = excluded.country_code,
        dial_code = excluded.dial_code,
        expires_at = excluded.expires_at,
        attempts_remaining = 3,
        created_at = now()
    `,
    [phoneNumber, debugCode, countryCode, dialCode, env.otpExpiresInSeconds],
  );

  if (isRedisConfigured()) {
    try {
      await setRedisString(cooldownKey, "1", env.otpResendInSeconds);
    } catch {
      // Si Redis no esta disponible, el flujo sigue funcionando con la base principal.
    }
  }

  return {
    phoneNumber,
    expiresInSeconds: env.otpExpiresInSeconds,
    resendInSeconds: env.otpResendInSeconds,
    debugCode,
  };
}

export async function verifyPhoneAuth(
  input: PhoneAuthVerifyInput,
): Promise<PhoneAuthSessionPayload> {
  if (!isDatabaseConfigured()) {
    return verifyPhoneAuthMock(input);
  }

  const phoneNumber = normalizeFullPhoneNumber(input.phoneNumber);
  const submittedCode = (input.code ?? "").trim();
  const env = getAppEnv();

  return withTransaction(async (client) => {
    const verificationResult = await runQuery<VerificationRow>(
      `
        select
          phone_number,
          code,
          country_code,
          dial_code,
          expires_at,
          attempts_remaining
        from phone_verification_codes
        where phone_number = $1
        for update
      `,
      [phoneNumber],
      client,
    );
    const verificationRecord = verificationResult.rows[0];

    if (!verificationRecord) {
      throw new Error("Primero solicita un código para ese teléfono.");
    }

    if (new Date(verificationRecord.expires_at).getTime() <= Date.now()) {
      await runQuery(
        "delete from phone_verification_codes where phone_number = $1",
        [phoneNumber],
        client,
      );
      throw new Error("El código venció. Solicita uno nuevo.");
    }

    if (!/^\d{6}$/.test(submittedCode)) {
      throw new Error("Ingresa un código de 6 dígitos.");
    }

    if (verificationRecord.code !== submittedCode) {
      if (verificationRecord.attempts_remaining <= 1) {
        await runQuery(
          "delete from phone_verification_codes where phone_number = $1",
          [phoneNumber],
          client,
        );
        throw new Error("Se agotaron los intentos. Solicita un nuevo código.");
      }

      await runQuery(
        `
          update phone_verification_codes
          set attempts_remaining = attempts_remaining - 1
          where phone_number = $1
        `,
        [phoneNumber],
        client,
      );
      throw new Error("El código ingresado no coincide.");
    }

    let identity = await findIdentityByPhone(phoneNumber, client);
    let user: UserProfile;

    if (!identity) {
      user = buildDefaultUser();
      await upsertUserProfile(user, client);
      await setPhoneIdentity(
        {
          phoneNumber,
          userId: user.id,
          countryCode: verificationRecord.country_code,
          dialCode: verificationRecord.dial_code,
          profileCompleted: false,
        },
        client,
      );
      identity = await findIdentityByPhone(phoneNumber, client);
    } else {
      user = await getDatabaseUser(identity.user_id, client);
    }

    const session: SessionRow = {
      access_token: `${randomUUID()}${randomUUID()}`.replaceAll("-", ""),
      refresh_token: `${randomUUID()}${randomUUID()}`.replaceAll("-", ""),
      user_id: user.id,
      phone_number: phoneNumber,
      expires_at: new Date(
        Date.now() + env.authSessionDays * 24 * 60 * 60 * 1000,
      ).toISOString(),
    };

    await runQuery(
      `
        insert into auth_sessions (
          access_token,
          refresh_token,
          user_id,
          phone_number,
          expires_at
        ) values ($1, $2, $3, $4, $5)
      `,
      [
        session.access_token,
        session.refresh_token,
        session.user_id,
        session.phone_number,
        session.expires_at,
      ],
      client,
    );

    await runQuery(
      "delete from phone_verification_codes where phone_number = $1",
      [phoneNumber],
      client,
    );

    return {
      accessToken: session.access_token,
      refreshToken: session.refresh_token,
      phoneNumber,
      profileCompleted: identity?.profile_completed ?? false,
      user,
    };
  });
}

export async function getProfile(userId?: string): Promise<UserProfile> {
  if (!isDatabaseConfigured()) {
    return getProfileMock(userId);
  }

  return getDatabaseUser(userId);
}

export async function updateCurrentUser(
  input: UpdateUserProfileInput,
  userId?: string,
): Promise<UserProfile> {
  if (!isDatabaseConfigured()) {
    return updateCurrentUserMock(input, userId);
  }

  const existingUser = await getDatabaseUser(userId);
  const updatedUser = mergeUserProfile(existingUser, input);

  await upsertUserProfile(updatedUser);
  await runQuery(
    `
      update phone_auth_identities
      set profile_completed = $2,
          updated_at = now()
      where user_id = $1
    `,
    [updatedUser.id, isProfileCompleted(updatedUser)],
  );

  return updatedUser;
}

export async function completePhoneProfile(
  accessToken: string,
  input: CompletePhoneProfileInput,
): Promise<PhoneAuthSessionPayload> {
  if (!isDatabaseConfigured()) {
    return completePhoneProfileMock(accessToken, input);
  }

  return withTransaction(async (client) => {
    const session = await findSessionByAccessToken(accessToken, client);
    if (!session || new Date(session.expires_at).getTime() <= Date.now()) {
      throw new Error(
        "La sesión ya no es válida. Vuelve a verificar tu teléfono.",
      );
    }

    const normalizedLocation =
      input.location?.trim() ||
      [input.city?.trim(), input.country?.trim()].filter(Boolean).join(", ");

    const existingUser = await getDatabaseUser(session.user_id, client);
    const updatedUser = mergeUserProfile(existingUser, {
      firstName: input.firstName?.trim(),
      lastName: input.lastName?.trim(),
      email: input.email?.trim(),
      location: normalizedLocation,
      accountType: input.accountType ?? "client",
      zodiacSign: input.zodiacSign?.trim() || inferZodiacSign(input.birthDate),
      natalChart: {
        subjectName: input.subjectName?.trim(),
        birthDate: normalizeBirthDateInput(input.birthDate),
        birthTime: input.birthTime?.trim(),
        birthTimeUnknown: Boolean(input.birthTimeUnknown),
        city: input.city?.trim(),
        state: input.state?.trim() ?? "",
        country: input.country?.trim(),
        timeZoneId: input.timeZoneId?.trim() ?? "",
        utcOffset: input.utcOffset?.trim() ?? "",
        latitude: typeof input.latitude === "number" ? input.latitude : null,
        longitude: typeof input.longitude === "number" ? input.longitude : null,
      },
    });

    await upsertUserProfile(updatedUser, client);
    await runQuery(
      `
        update phone_auth_identities
        set profile_completed = $2,
            updated_at = now()
        where user_id = $1
      `,
      [updatedUser.id, isProfileCompleted(updatedUser)],
      client,
    );

    return buildPhoneAuthSessionPayloadFromSession(session, client);
  });
}

export async function getBookings(userId?: string): Promise<Booking[]> {
  if (!isDatabaseConfigured()) {
    return getBookingsMock(userId);
  }

  const resolvedUserId = userId ?? demoUserId;
  const result = await runQuery<BookingRow>(
    `
      select
        id,
        user_id,
        service_id,
        service_name,
        specialist_id,
        specialist_name,
        scheduled_at,
        mode,
        status,
        price_amount,
        price_currency,
        notes
      from bookings
      where user_id = $1
      order by scheduled_at asc
    `,
    [resolvedUserId],
  );

  return result.rows.map(mapBookingRow);
}

export async function createBooking(
  input: CreateBookingInput,
  userId?: string,
): Promise<Booking> {
  if (!isDatabaseConfigured()) {
    return createBookingMock(input, userId);
  }

  const resolvedUserId = userId ?? demoUserId;
  if (
    !input.serviceId ||
    !input.specialistId ||
    !input.scheduledAt ||
    !input.mode
  ) {
    throw new Error("Faltan campos obligatorios para crear la reserva.");
  }

  const service = await getServiceById(input.serviceId);
  if (!service) {
    throw new Error("El servicio no existe.");
  }

  const specialist = getSpecialistById(input.specialistId);
  if (!specialist) {
    throw new Error("El especialista no existe.");
  }

  if (!service.specialistIds.includes(specialist.id)) {
    throw new Error("El especialista no ofrece ese servicio.");
  }

  if (!service.deliveryModes.includes(input.mode)) {
    throw new Error("Ese servicio no admite el modo seleccionado.");
  }

  const booking: Booking = {
    id: randomUUID(),
    userId: resolvedUserId,
    serviceId: service.id,
    serviceName: service.name,
    specialistId: specialist.id,
    specialistName: specialist.name,
    scheduledAt: input.scheduledAt,
    mode: input.mode,
    status: service.price.amount > 0 ? "pending_payment" : "confirmed",
    price: service.price,
    notes: input.notes ?? "",
  };

  await runQuery(
    `
      insert into bookings (
        id,
        user_id,
        service_id,
        service_name,
        specialist_id,
        specialist_name,
        scheduled_at,
        mode,
        status,
        price_amount,
        price_currency,
        notes,
        updated_at
      ) values (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, now()
      )
    `,
    [
      booking.id,
      booking.userId,
      booking.serviceId,
      booking.serviceName,
      booking.specialistId,
      booking.specialistName,
      booking.scheduledAt,
      booking.mode,
      booking.status,
      booking.price.amount,
      booking.price.currency,
      booking.notes,
    ],
  );

  return booking;
}

export async function updateBooking(
  bookingId: string,
  input: UpdateBookingInput,
  userId?: string,
): Promise<Booking> {
  if (!isDatabaseConfigured()) {
    return updateBookingMock(bookingId, input, userId);
  }

  const resolvedUserId = userId ?? demoUserId;
  const result = await runQuery<BookingRow>(
    `
      select
        id,
        user_id,
        service_id,
        service_name,
        specialist_id,
        specialist_name,
        scheduled_at,
        mode,
        status,
        price_amount,
        price_currency,
        notes
      from bookings
      where id = $1
        and user_id = $2
    `,
    [bookingId, resolvedUserId],
  );
  const bookingRow = result.rows[0];

  if (!bookingRow) {
    throw new Error("La reserva no existe.");
  }

  const booking = mapBookingRow(bookingRow);
  if (booking.status === "cancelled") {
    throw new Error("La reserva ya fue cancelada.");
  }
  if (booking.status === "completed") {
    throw new Error("No se puede modificar una reserva completada.");
  }

  const service = await getServiceById(booking.serviceId);
  if (!service) {
    throw new Error("El servicio asociado ya no existe.");
  }

  if (input.mode && !service.deliveryModes.includes(input.mode)) {
    throw new Error("Ese servicio no admite el modo seleccionado.");
  }

  if (input.scheduledAt) {
    const parsedDate = new Date(input.scheduledAt);
    if (Number.isNaN(parsedDate.getTime())) {
      throw new Error("La nueva fecha es inválida.");
    }
    if (parsedDate.getTime() <= Date.now()) {
      throw new Error("La nueva fecha debe estar en el futuro.");
    }
  }

  const updatedBooking: Booking = {
    ...booking,
    scheduledAt: input.scheduledAt?.trim() || booking.scheduledAt,
    mode: input.mode ?? booking.mode,
    notes: input.notes ?? booking.notes,
    status: input.status ?? booking.status,
  };

  await runQuery(
    `
      update bookings
      set scheduled_at = $3,
          mode = $4,
          notes = $5,
          status = $6,
          updated_at = now()
      where id = $1
        and user_id = $2
    `,
    [
      updatedBooking.id,
      updatedBooking.userId,
      updatedBooking.scheduledAt,
      updatedBooking.mode,
      updatedBooking.notes,
      updatedBooking.status,
    ],
  );

  return updatedBooking;
}

export async function getCurrentSubscription(
  userId?: string,
): Promise<Subscription> {
  return getCurrentSubscriptionBilling(userId);
}

async function listShopProducts(): Promise<ShopProduct[]> {
  const seedProducts = getShopDataMock().products.map(cloneShopProduct);
  const result = await runQuery<ShopProductOverrideRow>(
    `
      select
        product_id,
        name,
        category,
        short_description,
        description,
        price_amount,
        price_currency,
        image_url,
        artwork,
        badge,
        featured,
        stock_label,
        tags,
        created_at,
        updated_at
      from shop_product_overrides
      order by created_at desc
    `,
  );
  const overrides = new Map(
    result.rows.map((row) => [row.product_id, mapShopProductOverrideRow(row)]),
  );
  const seedProductIds = new Set(seedProducts.map((product) => product.id));
  const customProducts = result.rows
    .filter((row) => !seedProductIds.has(row.product_id))
    .map(mapShopProductOverrideRow);

  return [
    ...customProducts,
    ...seedProducts.map((product) => {
      const override = overrides.get(product.id);
      if (!override) {
        return product;
      }

      return {
        ...override,
        imageUrl: override.imageUrl.trim() || product.imageUrl,
        artwork: override.artwork.trim() || product.artwork,
      };
    }),
  ];
}

async function upsertShopProductOverride(product: ShopProduct): Promise<void> {
  await runQuery(
    `
      insert into shop_product_overrides (
        product_id,
        name,
        category,
        short_description,
        description,
        price_amount,
        price_currency,
        image_url,
        artwork,
        badge,
        featured,
        stock_label,
        tags,
        updated_at
      ) values (
        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13::jsonb, now()
      )
      on conflict (product_id) do update set
        name = excluded.name,
        category = excluded.category,
        short_description = excluded.short_description,
        description = excluded.description,
        price_amount = excluded.price_amount,
        price_currency = excluded.price_currency,
        image_url = excluded.image_url,
        artwork = excluded.artwork,
        badge = excluded.badge,
        featured = excluded.featured,
        stock_label = excluded.stock_label,
        tags = excluded.tags,
        updated_at = now()
    `,
    [
      product.id,
      product.name,
      product.category,
      product.shortDescription,
      product.description,
      product.price.amount,
      product.price.currency,
      product.imageUrl,
      product.artwork,
      product.badge,
      product.featured,
      product.stockLabel,
      JSON.stringify(product.tags),
    ],
  );
}

export async function getShopData(userId?: string): Promise<ShopData> {
  if (!isDatabaseConfigured()) {
    return getShopDataMock(userId);
  }

  const seed = getShopDataMock(userId);

  return {
    ...seed,
    products: await listShopProducts(),
    orders: await getShopOrders(userId),
  };
}

export async function getShopOrders(userId?: string): Promise<ShopOrder[]> {
  if (!isDatabaseConfigured()) {
    return getShopOrdersMock(userId);
  }

  const user = await getDatabaseUser(userId);
  const specialistScope = user.accountType === "specialist";
  const ordersResult = await runQuery<ShopOrderRow>(
    `
      select
        id,
        user_id,
        order_code,
        status,
        created_at,
        delivery_address,
        notes,
        subtotal_amount,
        subtotal_currency,
        shipping_amount,
        shipping_currency,
        total_amount,
        total_currency,
        item_count
      from shop_orders
      ${specialistScope ? "" : "where user_id = $1"}
      order by created_at desc
    `,
    specialistScope ? [] : [user.id],
  );

  if (ordersResult.rows.length === 0) {
    return getShopOrdersMock(specialistScope ? undefined : user.id);
  }

  const orderIds = ordersResult.rows.map((order) => order.id);
  const itemsResult = await runQuery<ShopOrderItemRow>(
    `
      select
        order_id,
        product_id,
        product_name,
        category,
        quantity,
        image_url,
        unit_price_amount,
        unit_price_currency,
        line_total_amount,
        line_total_currency
      from shop_order_items
      where order_id = any($1::text[])
      order by created_at asc
    `,
    [orderIds],
  );
  const itemsByOrderId = new Map<string, ShopOrderItemRow[]>();
  for (const item of itemsResult.rows) {
    const group = itemsByOrderId.get(item.order_id) ?? [];
    group.push(item);
    itemsByOrderId.set(item.order_id, group);
  }

  const databaseOrders = ordersResult.rows.map((order) =>
    mapShopOrderRows(order, itemsByOrderId.get(order.id) ?? []),
  );
  const seedOrders = getShopOrdersMock(specialistScope ? undefined : user.id);
  const databaseOrderIds = new Set(databaseOrders.map((order) => order.id));

  return [
    ...databaseOrders,
    ...seedOrders.filter((order) => !databaseOrderIds.has(order.id)),
  ];
}

export async function listServices(): Promise<ServiceOffer[]> {
  if (!isDatabaseConfigured()) {
    return getServices();
  }

  return listDatabaseServices();
}

export async function updateServiceOffer(
  serviceId: string,
  input: UpdateServiceOfferInput,
): Promise<ServiceOffer> {
  if (!isDatabaseConfigured()) {
    return updateServiceOfferMock(serviceId, input);
  }

  const service = await getServiceById(serviceId);
  if (!service) {
    throw new Error("El servicio no existe.");
  }

  const amount =
    input.price?.amount === undefined
      ? service.price.amount
      : Number(input.price.amount);
  if (!Number.isFinite(amount) || amount < 0) {
    throw new Error("Ingresa un precio válido.");
  }

  const durationMinutes =
    input.durationMinutes === undefined
      ? service.durationMinutes
      : Math.max(0, Math.round(Number(input.durationMinutes)));
  const updated: ServiceOffer = {
    ...service,
    durationMinutes,
    price: {
      amount: Number(amount.toFixed(2)),
      currency: input.price?.currency?.trim() || service.price.currency,
    },
  };

  await runQuery(
    `
      insert into service_offer_overrides (
        service_id,
        price_amount,
        price_currency,
        duration_minutes,
        updated_at
      ) values ($1, $2, $3, $4, now())
      on conflict (service_id) do update set
        price_amount = excluded.price_amount,
        price_currency = excluded.price_currency,
        duration_minutes = excluded.duration_minutes,
        updated_at = now()
    `,
    [
      updated.id,
      updated.price.amount,
      updated.price.currency,
      updated.durationMinutes,
    ],
  );

  return updated;
}

export async function createShopOrder(
  input: CreateShopOrderInput,
  userId?: string,
): Promise<ShopOrder> {
  if (!isDatabaseConfigured()) {
    return createShopOrderMock(input, userId);
  }

  const user = await getDatabaseUser(userId);
  const requestedItems = input.items ?? [];
  if (requestedItems.length === 0) {
    throw new Error("Agrega al menos un producto al carrito.");
  }

  const products = await listShopProducts();
  const items: ShopOrderItem[] = requestedItems.map((entry) => {
    const productId = entry.productId?.trim() ?? "";
    const quantity = Math.max(0, entry.quantity ?? 0);
    if (productId.length === 0 || quantity < 1) {
      throw new Error("El carrito contiene un producto inválido.");
    }

    const product = products.find((item) => item.id === productId);
    if (!product) {
      throw new Error("Uno de los productos ya no está disponible.");
    }

    return {
      productId: product.id,
      productName: product.name,
      category: product.category,
      quantity,
      imageUrl: product.imageUrl,
      unitPrice: cloneMoney(product.price),
      lineTotal: {
        amount: Number((product.price.amount * quantity).toFixed(2)),
        currency: product.price.currency,
      },
    };
  });
  const subtotalAmount = items.reduce(
    (sum, item) => sum + item.lineTotal.amount,
    0,
  );
  const shippingAmount = subtotalAmount >= 120 ? 0 : 9;
  const subtotal = {
    amount: Number(subtotalAmount.toFixed(2)),
    currency: "USD",
  };
  const shipping = { amount: shippingAmount, currency: "USD" };
  const total = {
    amount: Number((subtotal.amount + shipping.amount).toFixed(2)),
    currency: "USD",
  };
  const orderCountResult = await runQuery<{ count: string }>(
    "select count(*)::text as count from shop_orders where user_id = $1",
    [user.id],
  );
  const order: ShopOrder = {
    id: randomUUID(),
    userId: user.id,
    orderCode: buildOrderCode(Number(orderCountResult.rows[0]?.count ?? 0) + 1),
    status: "pending",
    createdAt: new Date().toISOString(),
    deliveryAddress:
      (input.deliveryAddress?.trim().length ?? 0) > 0
        ? input.deliveryAddress!.trim()
        : user.location,
    notes: input.notes?.trim() ?? "",
    subtotal,
    shipping,
    total,
    itemCount: items.reduce((sum, item) => sum + item.quantity, 0),
    items,
  };

  await withTransaction(async (client) => {
    await runQuery(
      `
        insert into shop_orders (
          id,
          user_id,
          order_code,
          status,
          created_at,
          delivery_address,
          notes,
          subtotal_amount,
          subtotal_currency,
          shipping_amount,
          shipping_currency,
          total_amount,
          total_currency,
          item_count,
          updated_at
        ) values (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, now()
        )
      `,
      [
        order.id,
        order.userId,
        order.orderCode,
        order.status,
        order.createdAt,
        order.deliveryAddress,
        order.notes,
        order.subtotal.amount,
        order.subtotal.currency,
        order.shipping.amount,
        order.shipping.currency,
        order.total.amount,
        order.total.currency,
        order.itemCount,
      ],
      client,
    );

    for (const item of order.items) {
      await runQuery(
        `
          insert into shop_order_items (
            id,
            order_id,
            product_id,
            product_name,
            category,
            quantity,
            image_url,
            unit_price_amount,
            unit_price_currency,
            line_total_amount,
            line_total_currency
          ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        `,
        [
          randomUUID(),
          order.id,
          item.productId,
          item.productName,
          item.category,
          item.quantity,
          item.imageUrl,
          item.unitPrice.amount,
          item.unitPrice.currency,
          item.lineTotal.amount,
          item.lineTotal.currency,
        ],
        client,
      );
    }
  });

  return order;
}

export async function createShopProduct(
  input: CreateShopProductInput,
): Promise<ShopProduct> {
  if (!isDatabaseConfigured()) {
    return createShopProductMock(input);
  }

  const name = input.name?.trim() ?? "";
  const category = input.category?.trim() ?? "";
  const amount = Number(input.price?.amount ?? 0);

  if (name.length < 3) {
    throw new Error("Ingresa un nombre de producto válido.");
  }
  if (category.length < 3) {
    throw new Error("Ingresa una categoría válida.");
  }
  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Ingresa un precio válido.");
  }

  const product: ShopProduct = {
    id: `shop-${slugifyShopValue(name)}-${randomUUID().slice(0, 8)}`,
    name,
    category,
    shortDescription:
      input.shortDescription?.trim() ||
      input.description?.trim() ||
      "Producto agregado desde administración.",
    description:
      input.description?.trim() ||
      input.shortDescription?.trim() ||
      "Producto agregado desde administración de tienda.",
    price: {
      amount: Number(amount.toFixed(2)),
      currency: input.price?.currency?.trim() || "USD",
    },
    imageUrl: input.imageUrl?.trim() ?? "",
    artwork: input.artwork?.trim() || inferShopArtwork(category),
    badge: input.badge?.trim() || "Nuevo",
    featured: input.featured ?? false,
    stockLabel: input.stockLabel?.trim() || "Disponible",
    tags: normalizeShopTags(input.tags),
  };

  await upsertShopProductOverride(product);
  return product;
}

export async function updateShopProduct(
  productId: string,
  input: UpdateShopProductInput,
): Promise<ShopProduct> {
  if (!isDatabaseConfigured()) {
    return updateShopProductMock(productId, input);
  }

  const existing = (await listShopProducts()).find(
    (item) => item.id === productId,
  );
  if (!existing) {
    throw new Error("El producto no existe.");
  }

  const amount =
    input.price?.amount === undefined
      ? existing.price.amount
      : Number(input.price.amount);

  if (!Number.isFinite(amount) || amount <= 0) {
    throw new Error("Ingresa un precio válido.");
  }

  const category = input.category?.trim() || existing.category;
  const updated: ShopProduct = {
    ...existing,
    name: input.name?.trim() || existing.name,
    category,
    shortDescription:
      input.shortDescription?.trim() || existing.shortDescription,
    description: input.description?.trim() || existing.description,
    price: {
      amount: Number(amount.toFixed(2)),
      currency: input.price?.currency?.trim() || existing.price.currency,
    },
    imageUrl: input.imageUrl?.trim() ?? existing.imageUrl,
    artwork:
      input.artwork?.trim() || existing.artwork || inferShopArtwork(category),
    badge: input.badge?.trim() || existing.badge,
    featured: input.featured ?? existing.featured,
    stockLabel: input.stockLabel?.trim() || existing.stockLabel,
    tags:
      input.tags === undefined ? existing.tags : normalizeShopTags(input.tags),
  };

  await upsertShopProductOverride(updated);
  return updated;
}

export async function updateShopOrderStatus(
  orderId: string,
  input: UpdateShopOrderStatusInput,
  userId?: string,
): Promise<ShopOrder> {
  if (!isDatabaseConfigured()) {
    return updateShopOrderStatusMock(orderId, input, userId);
  }

  const status = input.status;
  if (!isShopOrderStatus(status)) {
    throw new Error("Selecciona un estado de orden válido.");
  }

  const user = await getDatabaseUser(userId);
  const result = await runQuery<ShopOrderRow>(
    `
      update shop_orders
      set status = $2,
          updated_at = now()
      where id = $1
        ${user.accountType === "specialist" ? "" : "and user_id = $3"}
      returning
        id,
        user_id,
        order_code,
        status,
        created_at,
        delivery_address,
        notes,
        subtotal_amount,
        subtotal_currency,
        shipping_amount,
        shipping_currency,
        total_amount,
        total_currency,
        item_count
    `,
    user.accountType === "specialist"
      ? [orderId, status]
      : [orderId, status, user.id],
  );

  const row = result.rows[0];
  if (!row) {
    return updateShopOrderStatusMock(orderId, input, user.id);
  }

  const itemsResult = await runQuery<ShopOrderItemRow>(
    `
      select
        product_id,
        product_name,
        category,
        quantity,
        image_url,
        unit_price_amount,
        unit_price_currency,
        line_total_amount,
        line_total_currency
      from shop_order_items
      where order_id = $1
      order by created_at asc
    `,
    [row.id],
  );

  return mapShopOrderRows(row, itemsResult.rows);
}

export async function getHomePayload(userId?: string): Promise<HomePayload> {
  if (!isDatabaseConfigured()) {
    return getHomePayloadMock(userId);
  }

  const user = await getDatabaseUser(userId);
  const bookings = await getBookings(user.id);
  const upcoming = bookings.find(
    (booking) =>
      booking.status === "confirmed" || booking.status === "pending_payment",
  );
  const { cardOfTheDay, astrologicalEnergy } = buildDailyHomeContent(
    user.timezone,
  );

  return {
    welcomeTitle:
      user.firstName.trim().length === 0
        ? "Hola"
        : `Hola, ${user.firstName.trim()}`,
    welcomeSubtitle:
      "Tu espacio diario para tarot, astrología, consultas y contenido guiado.",
    cardOfTheDay,
    astrologicalEnergy,
    quickActions,
    upcomingBooking: upcoming
      ? {
          id: upcoming.id,
          specialistName: upcoming.specialistName,
          serviceName: upcoming.serviceName,
          scheduledAt: upcoming.scheduledAt,
          status: upcoming.status,
        }
      : null,
    featuredMessage:
      "La mejor primera versión prioriza agenda, contenido diario y una navegación clara por módulo.",
  };
}

export async function getBootstrap(userId?: string): Promise<AppBootstrap> {
  if (!isDatabaseConfigured()) {
    return getBootstrapMock(userId);
  }

  const user = await getDatabaseUser(userId);

  return {
    app: {
      name: "Lo Renaciente",
      tagline: "Autoconocimiento, guía y consultas en un mismo lugar.",
      market: "Perú / Latam",
      timezone: user.timezone,
    },
    user,
    home: await getHomePayload(user.id),
    plans: getPlans(),
    subscription: await getCurrentSubscription(user.id),
    payments: getPaymentsConfigBilling(),
    services: await listServices(),
    specialists: getSpecialists(),
    courses: getCourses(),
    shop: await getShopData(user.id),
    bookings: await getBookings(user.id),
    admin: getAdminSummary(),
  };
}
