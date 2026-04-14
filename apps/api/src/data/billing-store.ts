import { randomUUID } from "node:crypto";

import type { QueryResultRow } from "pg";

import { isDatabaseConfigured, query, withTransaction } from "../infrastructure/database.js";
import {
  getBookings as getBookingsMock,
  getCurrentSubscription as getCurrentSubscriptionMock,
  getPaymentsConfig as getPaymentsConfigMock,
  getPlans,
  setBookingStatus,
  setUserPlan,
  type Booking,
  type PaymentsConfig,
  type Subscription,
} from "./mock-store.js";

const demoUserId = "user-mark";
const subscriptionRenewalDays = 30;

export type BillingPlatform = "ios" | "android" | "web";
export type BillingProvider = "app_store" | "play_store" | "mercado_pago";
export type PaymentKind = "subscription" | "booking";
export type PaymentStatus = "pending" | "confirmed" | "failed" | "cancelled";

export interface CreatePaymentIntentInput {
  planId?: string;
  bookingId?: string;
  platform?: BillingPlatform;
  provider?: BillingProvider;
  method?: string;
  notes?: string;
}

export interface ConfirmPaymentInput {
  approvalCode?: string;
  notes?: string;
}

export interface CancelSubscriptionInput {
  reason?: string;
}

export interface PaymentTransaction {
  id: string;
  userId: string;
  kind: PaymentKind;
  planId: string | null;
  bookingId: string | null;
  amount: number;
  currency: string;
  provider: BillingProvider;
  platform: BillingPlatform;
  method: string;
  status: PaymentStatus;
  referenceCode: string;
  approvalCode: string;
  notes: string;
  createdAt: string;
  confirmedAt: string | null;
}

export interface PaymentIntent {
  payment: PaymentTransaction;
  paymentCode: string;
  paymentUrl: string;
  instructions: string[];
}

interface SubscriptionRow extends QueryResultRow {
  id: string;
  user_id: string;
  plan_id: string;
  status: Subscription["status"];
  platform: Subscription["platform"];
  billing_provider: Subscription["billingProvider"];
  started_at: Date | string;
  renews_at: Date | string | null;
  cancelled_at: Date | string | null;
}

interface PaymentRow extends QueryResultRow {
  id: string;
  user_id: string;
  kind: PaymentKind;
  plan_id: string | null;
  booking_id: string | null;
  amount: string | number;
  currency: string;
  provider: BillingProvider;
  platform: BillingPlatform;
  method: string;
  status: PaymentStatus;
  reference_code: string;
  approval_code: string;
  notes: string;
  created_at: Date | string;
  confirmed_at: Date | string | null;
}

const mockPayments: PaymentTransaction[] = [];
const mockSubscriptions = new Map<string, Subscription>([
  [demoUserId, getCurrentSubscriptionMock(demoUserId)],
]);

function toIsoString(value: Date | string | null): string | null {
  if (value == null) {
    return null;
  }
  if (value instanceof Date) {
    return value.toISOString();
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return String(value);
  }

  return parsed.toISOString();
}

function buildReferenceCode(kind: PaymentKind): string {
  const prefix = kind === "subscription" ? "SUB" : "BKG";
  return `${prefix}-${Math.floor(100000 + Math.random() * 900000)}`;
}

function resolvePlan(planId?: string) {
  const plan = getPlans().find((item) => item.id === planId);
  if (!plan) {
    throw new Error("El plan solicitado no existe.");
  }

  return plan;
}

async function getBookingForPayment(
  bookingId: string,
  userId: string,
): Promise<Booking> {
  if (!isDatabaseConfigured()) {
    const booking = getBookingsMock(userId).find((item) => item.id === bookingId);
    if (!booking) {
      throw new Error("La reserva no existe.");
    }

    return booking;
  }

  const result = await query<{
    id: string;
    user_id: string;
    service_id: string;
    service_name: string;
    specialist_id: string;
    specialist_name: string;
    scheduled_at: Date | string;
    mode: Booking["mode"];
    status: Booking["status"];
    price_amount: string | number;
    price_currency: string;
    notes: string;
  }>(
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
      limit 1
    `,
    [bookingId, userId],
  );
  const row = result.rows[0];
  if (!row) {
    throw new Error("La reserva no existe.");
  }

  return {
    id: row.id,
    userId: row.user_id,
    serviceId: row.service_id,
    serviceName: row.service_name,
    specialistId: row.specialist_id,
    specialistName: row.specialist_name,
    scheduledAt: toIsoString(row.scheduled_at) ?? "",
    mode: row.mode,
    status: row.status,
    price: {
      amount: Number(row.price_amount),
      currency: row.price_currency,
    },
    notes: row.notes,
  };
}

function resolveProvider(
  platform: BillingPlatform,
  provider?: BillingProvider,
): BillingProvider {
  if (provider) {
    return provider;
  }

  if (platform === "ios") {
    return "app_store";
  }
  if (platform === "android") {
    return "play_store";
  }

  return "mercado_pago";
}

function buildSubscriptionFromPlan(
  planId: string,
  status: Subscription["status"],
  platform: Subscription["platform"],
  billingProvider: Subscription["billingProvider"],
  renewsAt: string | null,
): Subscription {
  const plan = resolvePlan(planId);

  return {
    planId: plan.id,
    planName: plan.name,
    status,
    renewsAt,
    platform,
    billingProvider,
    entitlements: plan.features,
  };
}

function mapPaymentRow(row: PaymentRow): PaymentTransaction {
  return {
    id: row.id,
    userId: row.user_id,
    kind: row.kind,
    planId: row.plan_id,
    bookingId: row.booking_id,
    amount: Number(row.amount),
    currency: row.currency,
    provider: row.provider,
    platform: row.platform,
    method: row.method,
    status: row.status,
    referenceCode: row.reference_code,
    approvalCode: row.approval_code,
    notes: row.notes,
    createdAt: toIsoString(row.created_at) ?? new Date().toISOString(),
    confirmedAt: toIsoString(row.confirmed_at),
  };
}

function mapSubscriptionRow(row: SubscriptionRow): Subscription {
  return buildSubscriptionFromPlan(
    row.plan_id,
    row.status,
    row.platform,
    row.billing_provider,
    toIsoString(row.renews_at),
  );
}

async function upsertUserPlan(userId: string, planId: string): Promise<void> {
  if (!isDatabaseConfigured()) {
    return;
  }

  await query(
    `
      update users
      set plan_id = $2,
          updated_at = now()
      where id = $1
    `,
    [userId, planId],
  );
}

export function getPaymentsConfig(): PaymentsConfig {
  return getPaymentsConfigMock();
}

export async function getCurrentSubscription(userId?: string): Promise<Subscription> {
  const resolvedUserId = userId ?? demoUserId;

  if (!isDatabaseConfigured()) {
    return mockSubscriptions.get(resolvedUserId) ?? getCurrentSubscriptionMock(resolvedUserId);
  }

  const result = await query<SubscriptionRow>(
    `
      select
        id,
        user_id,
        plan_id,
        status,
        platform,
        billing_provider,
        started_at,
        renews_at,
        cancelled_at
      from user_subscriptions
      where user_id = $1
      order by created_at desc
      limit 1
    `,
    [resolvedUserId],
  );
  const row = result.rows[0];

  if (row) {
    return mapSubscriptionRow(row);
  }

  const userResult = await query<{ plan_id: string }>(
    `
      select plan_id
      from users
      where id = $1
      limit 1
    `,
    [resolvedUserId],
  );
  const userPlanId = userResult.rows[0]?.plan_id ?? "free";
  return buildSubscriptionFromPlan(userPlanId, userPlanId === "premium" ? "active" : "inactive", "web", userPlanId === "premium" ? "mercado_pago" : "mercado_pago", userPlanId === "premium" ? new Date(Date.now() + subscriptionRenewalDays * 24 * 60 * 60 * 1000).toISOString() : null);
}

export async function getPaymentHistory(userId?: string): Promise<PaymentTransaction[]> {
  const resolvedUserId = userId ?? demoUserId;

  if (!isDatabaseConfigured()) {
    return mockPayments
      .filter((item) => item.userId === resolvedUserId)
      .sort((left, right) => right.createdAt.localeCompare(left.createdAt));
  }

  const result = await query<PaymentRow>(
    `
      select
        id,
        user_id,
        kind,
        plan_id,
        booking_id,
        amount,
        currency,
        provider,
        platform,
        method,
        status,
        reference_code,
        approval_code,
        notes,
        created_at,
        confirmed_at
      from payment_transactions
      where user_id = $1
      order by created_at desc
    `,
    [resolvedUserId],
  );

  return result.rows.map(mapPaymentRow);
}

export async function createPaymentIntent(
  input: CreatePaymentIntentInput,
  userId?: string,
): Promise<PaymentIntent> {
  const resolvedUserId = userId ?? demoUserId;
  const targetPlanId = input.planId?.trim() || null;
  const targetBookingId = input.bookingId?.trim() || null;
  if ((targetPlanId == null && targetBookingId == null) || (targetPlanId != null && targetBookingId != null)) {
    throw new Error("Debes elegir exactamente un destino de pago: plan o reserva.");
  }

  const platform = input.platform ?? "web";
  const provider = resolveProvider(platform, input.provider);
  const method = input.method?.trim() || (targetPlanId ? "subscription" : "card");
  const referenceCode = buildReferenceCode(targetPlanId ? "subscription" : "booking");
  const approvalCode = randomUUID().slice(0, 8).toUpperCase();

  let amount = 0;
  let currency = "USD";
  let kind: PaymentKind = "subscription";

  if (targetPlanId) {
    const plan = resolvePlan(targetPlanId);
    amount = plan.priceMonthly;
    currency = plan.currency;
    kind = "subscription";
  } else if (targetBookingId) {
    const booking = await getBookingForPayment(targetBookingId, resolvedUserId);
    if (booking.status === "confirmed") {
      throw new Error("La reserva ya está pagada.");
    }
    if (booking.status === "cancelled") {
      throw new Error("No se puede pagar una reserva cancelada.");
    }
    amount = booking.price.amount;
    currency = booking.price.currency;
    kind = "booking";
  }

  const payment: PaymentTransaction = {
    id: randomUUID(),
    userId: resolvedUserId,
    kind,
    planId: targetPlanId,
    bookingId: targetBookingId,
    amount,
    currency,
    provider,
    platform,
    method,
    status: "pending",
    referenceCode,
    approvalCode: "",
    notes: input.notes?.trim() ?? "",
    createdAt: new Date().toISOString(),
    confirmedAt: null,
  };

  if (!isDatabaseConfigured()) {
    mockPayments.unshift(payment);
  } else {
    await query(
      `
        insert into payment_transactions (
          id,
          user_id,
          kind,
          plan_id,
          booking_id,
          amount,
          currency,
          provider,
          platform,
          method,
          status,
          reference_code,
          notes,
          updated_at
        ) values (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'pending', $11, $12, now()
        )
      `,
      [
        payment.id,
        payment.userId,
        payment.kind,
        payment.planId,
        payment.bookingId,
        payment.amount,
        payment.currency,
        payment.provider,
        payment.platform,
        payment.method,
        payment.referenceCode,
        payment.notes,
      ],
    );
  }

  return {
    payment,
    paymentCode: approvalCode,
    paymentUrl: `https://checkout.lo-renaciente.local/pay/${payment.referenceCode}`,
    instructions: [
      `Proveedor: ${provider}`,
      `Monto: ${currency} ${amount.toFixed(2)}`,
      `Referencia: ${payment.referenceCode}`,
      `Código sandbox para confirmar: ${approvalCode}`,
    ],
  };
}

export async function confirmPayment(
  paymentId: string,
  input: ConfirmPaymentInput,
  userId?: string,
): Promise<PaymentTransaction> {
  const resolvedUserId = userId ?? demoUserId;
  const submittedCode = input.approvalCode?.trim() ?? "";

  if (!isDatabaseConfigured()) {
    const payment = mockPayments.find((item) => item.id === paymentId && item.userId === resolvedUserId);
    if (!payment) {
      throw new Error("El pago no existe.");
    }
    if (payment.status !== "pending") {
      throw new Error("El pago ya fue procesado.");
    }
    if (submittedCode.length < 4) {
      throw new Error("Ingresa un código de aprobación válido.");
    }

    payment.status = "confirmed";
    payment.approvalCode = submittedCode;
    payment.confirmedAt = new Date().toISOString();
    payment.notes = input.notes?.trim() || payment.notes;

    if (payment.kind === "subscription" && payment.planId) {
      const renewedAt = new Date(
        Date.now() + subscriptionRenewalDays * 24 * 60 * 60 * 1000,
      ).toISOString();
      setUserPlan(payment.planId, resolvedUserId);
      mockSubscriptions.set(
        resolvedUserId,
        buildSubscriptionFromPlan(
          payment.planId,
          "active",
          payment.platform,
          payment.provider,
          renewedAt,
        ),
      );
    }

    if (payment.kind === "booking" && payment.bookingId) {
      setBookingStatus(payment.bookingId, "confirmed", resolvedUserId);
    }

    return payment;
  }

  return withTransaction(async (client) => {
    const paymentResult = await client.query<PaymentRow>(
      `
        select
          id,
          user_id,
          kind,
          plan_id,
          booking_id,
          amount,
          currency,
          provider,
          platform,
          method,
          status,
          reference_code,
          approval_code,
          notes,
          created_at,
          confirmed_at
        from payment_transactions
        where id = $1
          and user_id = $2
        for update
      `,
      [paymentId, resolvedUserId],
    );
    const paymentRow = paymentResult.rows[0];
    if (!paymentRow) {
      throw new Error("El pago no existe.");
    }
    if (paymentRow.status !== "pending") {
      throw new Error("El pago ya fue procesado.");
    }
    if (submittedCode.length < 4) {
      throw new Error("Ingresa un código de aprobación válido.");
    }

    const confirmedAt = new Date().toISOString();
    await client.query(
      `
        update payment_transactions
        set status = 'confirmed',
            approval_code = $3,
            notes = $4,
            confirmed_at = $5,
            updated_at = now()
        where id = $1
          and user_id = $2
      `,
      [paymentId, resolvedUserId, submittedCode, input.notes?.trim() ?? paymentRow.notes, confirmedAt],
    );

    if (paymentRow.kind === "subscription" && paymentRow.plan_id) {
      const renewsAt = new Date(
        Date.now() + subscriptionRenewalDays * 24 * 60 * 60 * 1000,
      ).toISOString();

      await client.query(
        `
          update user_subscriptions
          set status = 'inactive',
              cancelled_at = now(),
              updated_at = now()
          where user_id = $1
            and status = 'active'
        `,
        [resolvedUserId],
      );
      await client.query(
        `
          insert into user_subscriptions (
            id,
            user_id,
            plan_id,
            status,
            platform,
            billing_provider,
            started_at,
            renews_at,
            created_at,
            updated_at
          ) values (
            $1, $2, $3, 'active', $4, $5, now(), $6, now(), now()
          )
        `,
        [
          randomUUID(),
          resolvedUserId,
          paymentRow.plan_id,
          paymentRow.platform,
          paymentRow.provider,
          renewsAt,
        ],
      );
      await client.query(
        `
          update users
          set plan_id = $2,
              updated_at = now()
          where id = $1
        `,
        [resolvedUserId, paymentRow.plan_id],
      );
    }

    if (paymentRow.kind === "booking" && paymentRow.booking_id) {
      const bookingUpdate = await client.query(
        `
          update bookings
          set status = 'confirmed',
              updated_at = now()
          where id = $1
            and user_id = $2
            and status = 'pending_payment'
        `,
        [paymentRow.booking_id, resolvedUserId],
      );
      if (bookingUpdate.rowCount === 0) {
        throw new Error("La reserva ya no admite este pago.");
      }
    }

    return {
      ...mapPaymentRow(paymentRow),
      status: "confirmed",
      approvalCode: submittedCode,
      notes: input.notes?.trim() ?? paymentRow.notes,
      confirmedAt,
    };
  });
}

export async function cancelCurrentSubscription(
  input: CancelSubscriptionInput,
  userId?: string,
): Promise<Subscription> {
  const resolvedUserId = userId ?? demoUserId;
  const reason = input.reason?.trim() ?? "";

  if (!isDatabaseConfigured()) {
    setUserPlan("free", resolvedUserId);
    const cancelled = buildSubscriptionFromPlan("free", "inactive", "web", "mercado_pago", null);
    mockSubscriptions.set(resolvedUserId, cancelled);
    return cancelled;
  }

  await query(
    `
      update user_subscriptions
      set status = 'inactive',
          cancelled_at = now(),
          cancel_reason = $2,
          updated_at = now()
      where user_id = $1
        and status = 'active'
    `,
    [resolvedUserId, reason],
  );
  await upsertUserPlan(resolvedUserId, "free");

  return buildSubscriptionFromPlan("free", "inactive", "web", "mercado_pago", null);
}
