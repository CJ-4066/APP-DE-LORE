import type { QueryResultRow } from "pg";

import { isDatabaseConfigured, query } from "../infrastructure/database.js";
import {
  getAdminSummary as getAdminSummaryMock,
  getBookings as getBookingsMock,
  getProfile as getProfileMock,
  getSpecialists,
  type BookingStatus,
  type SessionMode,
} from "./mock-store.js";

export interface AdminDashboardSummary {
  activeUsers: number;
  premiumSubscribers: number;
  monthlyBookings: number;
  activeSpecialists: number;
  openIncidents: number;
  openChatThreads: number;
  registeredPushDevices: number;
  pendingPaymentBookings: number;
}

export interface AdminRecentBooking {
  id: string;
  userId: string;
  userName: string;
  specialistName: string;
  serviceName: string;
  scheduledAt: string;
  status: BookingStatus;
  mode: SessionMode;
}

export interface AdminRecentUser {
  id: string;
  fullName: string;
  email: string;
  phoneNumber: string;
  planId: string;
  profileCompleted: boolean;
  createdAt: string;
}

export interface AdminChatOverview {
  totalThreads: number;
  openThreads: number;
  totalMessages: number;
  recentThreads: Array<{
    id: string;
    userId: string;
    userName: string;
    specialistId: string;
    specialistName: string;
    status: string;
    lastMessageAt: string | null;
    lastMessagePreview: string;
  }>;
}

interface SummaryRow extends QueryResultRow {
  active_users: string;
  premium_subscribers: string;
  monthly_bookings: string;
  open_chat_threads: string;
  registered_push_devices: string;
  pending_payment_bookings: string;
}

interface AdminBookingRow extends QueryResultRow {
  id: string;
  user_id: string;
  user_name: string;
  specialist_name: string;
  service_name: string;
  scheduled_at: Date | string;
  status: BookingStatus;
  mode: SessionMode;
}

interface AdminUserRow extends QueryResultRow {
  id: string;
  full_name: string;
  email: string;
  phone_number: string | null;
  plan_id: string;
  profile_completed: boolean | null;
  created_at: Date | string;
}

interface ChatCountsRow extends QueryResultRow {
  total_threads: string;
  open_threads: string;
  total_messages: string;
}

interface AdminThreadRow extends QueryResultRow {
  id: string;
  user_id: string;
  user_name: string;
  specialist_id: string;
  status: string;
  last_message_at: Date | string | null;
  last_message_preview: string | null;
}

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

function getSpecialistName(specialistId: string): string {
  return getSpecialists().find((item) => item.id === specialistId)?.name ?? specialistId;
}

export async function getAdminDashboardSummary(): Promise<AdminDashboardSummary> {
  if (!isDatabaseConfigured()) {
    const summary = getAdminSummaryMock();
    return {
      activeUsers: summary.activeUsers,
      premiumSubscribers: summary.premiumSubscribers,
      monthlyBookings: summary.monthlyBookings,
      activeSpecialists: summary.activeSpecialists,
      openIncidents: summary.openIncidents,
      openChatThreads: 1,
      registeredPushDevices: 0,
      pendingPaymentBookings: getBookingsMock().filter(
        (item) => item.status === "pending_payment",
      ).length,
    };
  }

  const result = await query<SummaryRow>(
    `
      select
        (select count(*)::text from users) as active_users,
        (
          select count(distinct user_id)::text
          from user_subscriptions
          where plan_id = 'premium'
            and status = 'active'
        ) as premium_subscribers,
        (
          select count(*)::text
          from bookings
          where date_trunc('month', scheduled_at) = date_trunc('month', now())
        ) as monthly_bookings,
        (select count(*)::text from chat_threads where status = 'open') as open_chat_threads,
        (select count(*)::text from push_devices) as registered_push_devices,
        (
          select count(*)::text
          from bookings
          where status = 'pending_payment'
        ) as pending_payment_bookings
    `,
  );
  const row = result.rows[0];

  return {
    activeUsers: Number(row.active_users),
    premiumSubscribers: Number(row.premium_subscribers),
    monthlyBookings: Number(row.monthly_bookings),
    activeSpecialists: getSpecialists().length,
    openIncidents: 0,
    openChatThreads: Number(row.open_chat_threads),
    registeredPushDevices: Number(row.registered_push_devices),
    pendingPaymentBookings: Number(row.pending_payment_bookings),
  };
}

export async function getAdminRecentBookings(limit = 10): Promise<AdminRecentBooking[]> {
  const safeLimit = Math.max(1, Math.min(limit, 50));

  if (!isDatabaseConfigured()) {
    const user = getProfileMock();
    const userName = `${user.firstName} ${user.lastName}`.trim() || user.nickname || user.id;

    return getBookingsMock()
      .slice()
      .sort((left, right) => right.scheduledAt.localeCompare(left.scheduledAt))
      .slice(0, safeLimit)
      .map((booking) => ({
        id: booking.id,
        userId: booking.userId,
        userName,
        specialistName: booking.specialistName,
        serviceName: booking.serviceName,
        scheduledAt: booking.scheduledAt,
        status: booking.status,
        mode: booking.mode,
      }));
  }

  const result = await query<AdminBookingRow>(
    `
      select
        b.id,
        b.user_id,
        coalesce(nullif(trim(concat_ws(' ', u.first_name, u.last_name)), ''), u.nickname, u.email, b.user_id) as user_name,
        b.specialist_name,
        b.service_name,
        b.scheduled_at,
        b.status,
        b.mode
      from bookings b
      left join users u on u.id = b.user_id
      order by b.scheduled_at desc
      limit $1
    `,
    [safeLimit],
  );

  return result.rows.map((row) => ({
    id: row.id,
    userId: row.user_id,
    userName: row.user_name,
    specialistName: row.specialist_name,
    serviceName: row.service_name,
    scheduledAt: toIsoString(row.scheduled_at) ?? "",
    status: row.status,
    mode: row.mode,
  }));
}

export async function getAdminRecentUsers(limit = 10): Promise<AdminRecentUser[]> {
  const safeLimit = Math.max(1, Math.min(limit, 50));

  if (!isDatabaseConfigured()) {
    const user = getProfileMock();
    return [
      {
        id: user.id,
        fullName: `${user.firstName} ${user.lastName}`.trim(),
        email: user.email,
        phoneNumber: "+59891111111",
        planId: user.planId,
        profileCompleted: true,
        createdAt: new Date().toISOString(),
      },
    ].slice(0, safeLimit);
  }

  const result = await query<AdminUserRow>(
    `
      select
        u.id,
        coalesce(nullif(trim(concat_ws(' ', u.first_name, u.last_name)), ''), u.nickname, u.email, u.id) as full_name,
        u.email,
        i.phone_number,
        u.plan_id,
        i.profile_completed,
        u.created_at
      from users u
      left join phone_auth_identities i on i.user_id = u.id
      order by u.created_at desc
      limit $1
    `,
    [safeLimit],
  );

  return result.rows.map((row) => ({
    id: row.id,
    fullName: row.full_name,
    email: row.email,
    phoneNumber: row.phone_number ?? "",
    planId: row.plan_id,
    profileCompleted: row.profile_completed ?? false,
    createdAt: toIsoString(row.created_at) ?? "",
  }));
}

export async function getAdminChatOverview(limit = 10): Promise<AdminChatOverview> {
  const safeLimit = Math.max(1, Math.min(limit, 50));

  if (!isDatabaseConfigured()) {
    return {
      totalThreads: 1,
      openThreads: 1,
      totalMessages: 2,
      recentThreads: [
        {
          id: "thread-demo-amaya",
          userId: "user-mark",
          userName: "Mark Lore",
          specialistId: "spec-amaya",
          specialistName: getSpecialistName("spec-amaya"),
          status: "open",
          lastMessageAt: "2026-03-24T15:06:00.000Z",
          lastMessagePreview: "Perfecto, quiero enfocarme en claridad laboral y vínculos.",
        },
      ],
    };
  }

  const [countsResult, threadsResult] = await Promise.all([
    query<ChatCountsRow>(
      `
        select
          (select count(*)::text from chat_threads) as total_threads,
          (select count(*)::text from chat_threads where status = 'open') as open_threads,
          (select count(*)::text from chat_messages) as total_messages
      `,
    ),
    query<AdminThreadRow>(
      `
        select
          t.id,
          t.user_id,
          coalesce(nullif(trim(concat_ws(' ', u.first_name, u.last_name)), ''), u.nickname, u.email, t.user_id) as user_name,
          t.specialist_id,
          t.status,
          (
            select m.created_at
            from chat_messages m
            where m.thread_id = t.id
            order by m.created_at desc
            limit 1
          ) as last_message_at,
          (
            select m.body
            from chat_messages m
            where m.thread_id = t.id
            order by m.created_at desc
            limit 1
          ) as last_message_preview
        from chat_threads t
        left join users u on u.id = t.user_id
        order by coalesce(
          (
            select m.created_at
            from chat_messages m
            where m.thread_id = t.id
            order by m.created_at desc
            limit 1
          ),
          t.updated_at
        ) desc
        limit $1
      `,
      [safeLimit],
    ),
  ]);

  const counts = countsResult.rows[0];
  return {
    totalThreads: Number(counts.total_threads),
    openThreads: Number(counts.open_threads),
    totalMessages: Number(counts.total_messages),
    recentThreads: threadsResult.rows.map((row) => ({
      id: row.id,
      userId: row.user_id,
      userName: row.user_name,
      specialistId: row.specialist_id,
      specialistName: getSpecialistName(row.specialist_id),
      status: row.status,
      lastMessageAt: toIsoString(row.last_message_at),
      lastMessagePreview: row.last_message_preview ?? "",
    })),
  };
}
