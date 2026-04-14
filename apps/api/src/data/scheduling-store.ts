import { randomUUID } from "node:crypto";

import type { QueryResultRow } from "pg";

import { isDatabaseConfigured, query } from "../infrastructure/database.js";
import {
  createBooking as createBookingBase,
  getBookings as getBookingsBase,
  updateBooking as updateBookingBase,
} from "./persistent-store.js";
import {
  getServices,
  getSpecialists,
  type Booking,
  type BookingStatus,
  type CreateBookingInput,
  type ServiceOffer,
  type SessionMode,
  type Specialist,
  type UpdateBookingInput,
} from "./mock-store.js";

const demoUserId = "user-mark";
const cancellationWindowHours = 6;
const rescheduleWindowHours = 12;

export interface SpecialistAvailabilitySlot {
  id: string;
  specialistId: string;
  startsAt: string;
  endsAt: string;
  mode: SessionMode;
  isAvailable: boolean;
}

export interface ListSpecialistAvailabilityOptions {
  from?: string;
  to?: string;
  mode?: SessionMode;
}

export interface UpsertSpecialistAvailabilityInput {
  specialistId?: string;
  startsAt?: string;
  endsAt?: string;
  mode?: SessionMode;
  isAvailable?: boolean;
}

export interface BookingPolicy {
  bookingId: string;
  status: BookingStatus;
  scheduledAt: string;
  hoursUntilSession: number;
  canCancel: boolean;
  canReschedule: boolean;
  cancellationWindowHours: number;
  rescheduleWindowHours: number;
  message: string;
}

export interface BookingAuditEntry {
  id: string;
  actorType: string;
  actorId: string;
  eventType: string;
  entityType: string;
  entityId: string;
  payload: Record<string, unknown>;
  createdAt: string;
}

interface AvailabilityRow extends QueryResultRow {
  id: string;
  specialist_id: string;
  starts_at: Date | string;
  ends_at: Date | string;
  mode: SessionMode;
  is_available: boolean;
}

interface BookingWindowRow extends QueryResultRow {
  id: string;
  service_id: string;
  scheduled_at: Date | string;
  mode: SessionMode;
  status: BookingStatus;
}

interface AuditRow extends QueryResultRow {
  id: string;
  actor_type: string;
  actor_id: string;
  event_type: string;
  entity_type: string;
  entity_id: string;
  payload: Record<string, unknown>;
  created_at: Date | string;
}

const mockAvailabilitySlots = new Map<string, SpecialistAvailabilitySlot>();
const mockAuditLog: BookingAuditEntry[] = [];

function getServiceById(serviceId: string): ServiceOffer | null {
  return getServices().find((item) => item.id === serviceId) ?? null;
}

function getSpecialistById(specialistId: string): Specialist | null {
  return getSpecialists().find((item) => item.id === specialistId) ?? null;
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

function parseRequiredDate(value: string | undefined, fieldName: string): Date {
  const parsed = new Date(value ?? "");
  if (Number.isNaN(parsed.getTime())) {
    throw new Error(`${fieldName} no es válida.`);
  }

  return parsed;
}

function addMinutes(date: Date, minutes: number): Date {
  return new Date(date.getTime() + minutes * 60 * 1000);
}

function hoursUntil(dateIso: string): number {
  const scheduledAt = new Date(dateIso);
  return Number(((scheduledAt.getTime() - Date.now()) / (60 * 60 * 1000)).toFixed(1));
}

function rangesOverlap(
  startsAt: Date,
  endsAt: Date,
  otherStartsAt: Date,
  otherEndsAt: Date,
): boolean {
  return startsAt.getTime() < otherEndsAt.getTime() &&
    otherStartsAt.getTime() < endsAt.getTime();
}

function mapAvailabilityRow(row: AvailabilityRow): SpecialistAvailabilitySlot {
  return {
    id: row.id,
    specialistId: row.specialist_id,
    startsAt: toIsoString(row.starts_at),
    endsAt: toIsoString(row.ends_at),
    mode: row.mode,
    isAvailable: row.is_available,
  };
}

function mapAuditRow(row: AuditRow): BookingAuditEntry {
  return {
    id: row.id,
    actorType: row.actor_type,
    actorId: row.actor_id,
    eventType: row.event_type,
    entityType: row.entity_type,
    entityId: row.entity_id,
    payload: row.payload ?? {},
    createdAt: toIsoString(row.created_at),
  };
}

function buildPolicy(booking: Booking): BookingPolicy {
  const sessionHoursUntil = hoursUntil(booking.scheduledAt);

  if (booking.status === "cancelled") {
    return {
      bookingId: booking.id,
      status: booking.status,
      scheduledAt: booking.scheduledAt,
      hoursUntilSession: sessionHoursUntil,
      canCancel: false,
      canReschedule: false,
      cancellationWindowHours,
      rescheduleWindowHours,
      message: "La reserva ya fue cancelada.",
    };
  }

  if (booking.status === "completed") {
    return {
      bookingId: booking.id,
      status: booking.status,
      scheduledAt: booking.scheduledAt,
      hoursUntilSession: sessionHoursUntil,
      canCancel: false,
      canReschedule: false,
      cancellationWindowHours,
      rescheduleWindowHours,
      message: "La reserva ya fue completada.",
    };
  }

  if (sessionHoursUntil <= 0) {
    return {
      bookingId: booking.id,
      status: booking.status,
      scheduledAt: booking.scheduledAt,
      hoursUntilSession: sessionHoursUntil,
      canCancel: false,
      canReschedule: false,
      cancellationWindowHours,
      rescheduleWindowHours,
      message: "La sesión ya comenzó o ya pasó.",
    };
  }

  const canCancel = sessionHoursUntil >= cancellationWindowHours;
  const canReschedule = sessionHoursUntil >= rescheduleWindowHours;

  return {
    bookingId: booking.id,
    status: booking.status,
    scheduledAt: booking.scheduledAt,
    hoursUntilSession: sessionHoursUntil,
    canCancel,
    canReschedule,
    cancellationWindowHours,
    rescheduleWindowHours,
    message:
      canCancel && canReschedule
        ? "La reserva puede cancelarse o reprogramarse desde la app."
        : canCancel
          ? `La reserva ya no puede reprogramarse a menos de ${rescheduleWindowHours} horas.`
          : `La reserva no puede cancelarse a menos de ${cancellationWindowHours} horas de la sesión.`,
  };
}

function buildDemoAvailabilitySlots(
  specialist: Specialist,
  options: ListSpecialistAvailabilityOptions,
): SpecialistAvailabilitySlot[] {
  const from = options.from ? parseRequiredDate(options.from, "La fecha inicial") : new Date();
  const to = options.to
    ? parseRequiredDate(options.to, "La fecha final")
    : new Date(from.getTime() + 14 * 24 * 60 * 60 * 1000);
  const base = new Date(specialist.nextAvailableAt);
  const slots: SpecialistAvailabilitySlot[] = [];

  for (let dayOffset = 0; dayOffset < 14; dayOffset += 1) {
    specialist.sessionModes.forEach((mode, modeIndex) => {
      const startsAt = new Date(
        Math.max(base.getTime(), from.getTime()) +
          dayOffset * 24 * 60 * 60 * 1000 +
          modeIndex * 105 * 60 * 1000,
      );
      const endsAt = addMinutes(startsAt, 90);

      slots.push({
        id: `${specialist.id}-demo-${dayOffset}-${mode}`,
        specialistId: specialist.id,
        startsAt: startsAt.toISOString(),
        endsAt: endsAt.toISOString(),
        mode,
        isAvailable: true,
      });
    });
  }

  return slots.filter((slot) => {
    const startsAt = new Date(slot.startsAt);
    const matchesMode = options.mode ? slot.mode === options.mode : true;
    return matchesMode && startsAt.getTime() >= from.getTime() && startsAt.getTime() <= to.getTime();
  });
}

async function getDatabaseNextAvailabilityMap(): Promise<Map<string, string>> {
  const result = await query<{ specialist_id: string; next_available_at: Date | string }>(
    `
      select specialist_id, min(starts_at) as next_available_at
      from specialist_availability
      where is_available = true
        and starts_at > now()
      group by specialist_id
    `,
  );

  return new Map(
    result.rows.map((row) => [row.specialist_id, toIsoString(row.next_available_at)]),
  );
}

async function hasConfiguredAvailability(
  specialistId: string,
  mode: SessionMode,
): Promise<boolean> {
  if (!isDatabaseConfigured()) {
    return [...mockAvailabilitySlots.values()].some(
      (slot) => slot.specialistId === specialistId && slot.mode === mode,
    );
  }

  const result = await query<{ count: string }>(
    `
      select count(*)::text as count
      from specialist_availability
      where specialist_id = $1
        and mode = $2
        and is_available = true
        and ends_at > now()
    `,
    [specialistId, mode],
  );

  return Number(result.rows[0]?.count ?? "0") > 0;
}

async function hasAvailabilityCoverage(
  specialistId: string,
  mode: SessionMode,
  startsAt: Date,
  endsAt: Date,
): Promise<boolean> {
  if (!isDatabaseConfigured()) {
    return [...mockAvailabilitySlots.values()].some((slot) => {
      if (slot.specialistId !== specialistId || slot.mode !== mode || !slot.isAvailable) {
        return false;
      }

      const slotStartsAt = new Date(slot.startsAt);
      const slotEndsAt = new Date(slot.endsAt);
      return slotStartsAt.getTime() <= startsAt.getTime() &&
        slotEndsAt.getTime() >= endsAt.getTime();
    });
  }

  const result = await query<{ id: string }>(
    `
      select id
      from specialist_availability
      where specialist_id = $1
        and mode = $2
        and is_available = true
        and starts_at <= $3
        and ends_at >= $4
      limit 1
    `,
    [specialistId, mode, startsAt.toISOString(), endsAt.toISOString()],
  );

  return Boolean(result.rows[0]);
}

async function hasConflictingBooking(
  specialistId: string,
  startsAt: Date,
  endsAt: Date,
  excludeBookingId?: string,
): Promise<boolean> {
  if (!isDatabaseConfigured()) {
    const bookings = await getBookingsBase(demoUserId);
    return bookings.some((booking) => {
        if (excludeBookingId && booking.id === excludeBookingId) {
          return false;
        }
        if (booking.specialistId !== specialistId) {
          return false;
        }
        if (booking.status === "cancelled" || booking.status === "completed") {
          return false;
        }

        const service = getServiceById(booking.serviceId);
        if (!service) {
          return false;
        }

        const bookingStartsAt = new Date(booking.scheduledAt);
        const bookingEndsAt = addMinutes(bookingStartsAt, service.durationMinutes);
        return rangesOverlap(startsAt, endsAt, bookingStartsAt, bookingEndsAt);
      });
  }

  const params: unknown[] = [
    specialistId,
    new Date(startsAt.getTime() - 6 * 60 * 60 * 1000).toISOString(),
    new Date(endsAt.getTime() + 6 * 60 * 60 * 1000).toISOString(),
  ];
  let excludeClause = "";

  if (excludeBookingId) {
    params.push(excludeBookingId);
    excludeClause = `and id <> $4`;
  }

  const result = await query<BookingWindowRow>(
    `
      select id, service_id, scheduled_at, mode, status
      from bookings
      where specialist_id = $1
        and status in ('confirmed', 'pending_payment')
        and scheduled_at >= $2
        and scheduled_at <= $3
        ${excludeClause}
      order by scheduled_at asc
    `,
    params,
  );

  for (const row of result.rows) {
    const service = getServiceById(row.service_id);
    if (!service) {
      continue;
    }

    const bookingStartsAt = new Date(row.scheduled_at);
    const bookingEndsAt = addMinutes(bookingStartsAt, service.durationMinutes);
    if (rangesOverlap(startsAt, endsAt, bookingStartsAt, bookingEndsAt)) {
      return true;
    }
  }

  return false;
}

async function logAudit(
  actorType: string,
  actorId: string,
  eventType: string,
  entityType: string,
  entityId: string,
  payload: Record<string, unknown>,
): Promise<void> {
  const entry: BookingAuditEntry = {
    id: randomUUID(),
    actorType,
    actorId,
    eventType,
    entityType,
    entityId,
    payload,
    createdAt: new Date().toISOString(),
  };

  if (!isDatabaseConfigured()) {
    mockAuditLog.unshift(entry);
    return;
  }

  await query(
    `
      insert into audit_logs (
        id,
        actor_type,
        actor_id,
        event_type,
        entity_type,
        entity_id,
        payload
      ) values ($1, $2, $3, $4, $5, $6, $7::jsonb)
    `,
    [
      entry.id,
      entry.actorType,
      entry.actorId,
      entry.eventType,
      entry.entityType,
      entry.entityId,
      JSON.stringify(entry.payload),
    ],
  );
}

async function assertBookableSlot(
  service: ServiceOffer,
  specialist: Specialist,
  startsAtIso: string,
  mode: SessionMode,
  excludeBookingId?: string,
): Promise<void> {
  const startsAt = parseRequiredDate(startsAtIso, "La fecha de la reserva");
  if (startsAt.getTime() <= Date.now()) {
    throw new Error("La reserva debe programarse en el futuro.");
  }

  if (!specialist.sessionModes.includes(mode)) {
    throw new Error("El especialista no atiende en el modo seleccionado.");
  }

  const endsAt = addMinutes(startsAt, service.durationMinutes);
  const availabilityConfigured = await hasConfiguredAvailability(specialist.id, mode);
  if (availabilityConfigured) {
    const hasCoverage = await hasAvailabilityCoverage(
      specialist.id,
      mode,
      startsAt,
      endsAt,
    );
    if (!hasCoverage) {
      throw new Error("El especialista no tiene disponibilidad activa para ese horario.");
    }
  }

  const hasConflict = await hasConflictingBooking(
    specialist.id,
    startsAt,
    endsAt,
    excludeBookingId,
  );
  if (hasConflict) {
    throw new Error("Ya existe otra reserva que se cruza con ese horario.");
  }
}

function getBookingFromCollection(bookings: Booking[], bookingId: string): Booking {
  const booking = bookings.find((item) => item.id === bookingId);
  if (!booking) {
    throw new Error("La reserva no existe.");
  }

  return booking;
}

export async function getSpecialistCatalog(): Promise<Specialist[]> {
  const specialists = getSpecialists();
  if (!isDatabaseConfigured()) {
    return specialists;
  }

  const availabilityMap = await getDatabaseNextAvailabilityMap();
  return specialists.map((specialist) => ({
    ...specialist,
    nextAvailableAt:
      availabilityMap.get(specialist.id) ?? specialist.nextAvailableAt,
  }));
}

export async function getFeaturedSpecialists(): Promise<Specialist[]> {
  return (await getSpecialistCatalog()).filter((item) => item.featured);
}

export async function getSpecialistAvailability(
  specialistId: string,
  options: ListSpecialistAvailabilityOptions = {},
): Promise<SpecialistAvailabilitySlot[]> {
  const specialist = getSpecialistById(specialistId);
  if (!specialist) {
    throw new Error("El especialista no existe.");
  }

  if (!isDatabaseConfigured()) {
    const customSlots = [...mockAvailabilitySlots.values()].filter(
      (slot) =>
        slot.specialistId === specialistId &&
        (options.mode ? slot.mode === options.mode : true),
    );

    if (customSlots.length > 0) {
      return customSlots.sort((left, right) => left.startsAt.localeCompare(right.startsAt));
    }

    return buildDemoAvailabilitySlots(specialist, options);
  }

  const from = options.from ? parseRequiredDate(options.from, "La fecha inicial") : new Date();
  const to = options.to
    ? parseRequiredDate(options.to, "La fecha final")
    : new Date(from.getTime() + 14 * 24 * 60 * 60 * 1000);
  if (to.getTime() <= from.getTime()) {
    throw new Error("La fecha final debe ser posterior a la inicial.");
  }

  const params: unknown[] = [specialistId, from.toISOString(), to.toISOString()];
  let modeClause = "";
  if (options.mode) {
    params.push(options.mode);
    modeClause = "and mode = $4";
  }

  const result = await query<AvailabilityRow>(
    `
      select id, specialist_id, starts_at, ends_at, mode, is_available
      from specialist_availability
      where specialist_id = $1
        and ends_at >= $2
        and starts_at <= $3
        ${modeClause}
      order by starts_at asc
    `,
    params,
  );

  if (result.rows.length === 0) {
    return buildDemoAvailabilitySlots(specialist, options);
  }

  return result.rows.map(mapAvailabilityRow);
}

export async function upsertSpecialistAvailability(
  input: UpsertSpecialistAvailabilityInput,
): Promise<SpecialistAvailabilitySlot> {
  const specialistId = input.specialistId?.trim();
  if (!specialistId || !getSpecialistById(specialistId)) {
    throw new Error("Selecciona un especialista válido.");
  }
  if (!input.mode || !["chat", "audio", "video"].includes(input.mode)) {
    throw new Error("Selecciona un modo válido.");
  }

  const specialist = getSpecialistById(specialistId);
  if (!specialist?.sessionModes.includes(input.mode)) {
    throw new Error("Ese especialista no trabaja en el modo elegido.");
  }

  const startsAt = parseRequiredDate(input.startsAt, "La fecha inicial");
  const endsAt = parseRequiredDate(input.endsAt, "La fecha final");
  if (endsAt.getTime() <= startsAt.getTime()) {
    throw new Error("La fecha final debe ser posterior a la inicial.");
  }

  const slot: SpecialistAvailabilitySlot = {
    id: randomUUID(),
    specialistId,
    startsAt: startsAt.toISOString(),
    endsAt: endsAt.toISOString(),
    mode: input.mode,
    isAvailable: input.isAvailable ?? true,
  };

  if (!isDatabaseConfigured()) {
    mockAvailabilitySlots.set(slot.id, slot);
    return slot;
  }

  await query(
    `
      insert into specialist_availability (
        id,
        specialist_id,
        starts_at,
        ends_at,
        mode,
        is_available,
        updated_at
      ) values ($1, $2, $3, $4, $5, $6, now())
    `,
    [
      slot.id,
      slot.specialistId,
      slot.startsAt,
      slot.endsAt,
      slot.mode,
      slot.isAvailable,
    ],
  );

  return slot;
}

export async function deleteSpecialistAvailability(availabilityId: string): Promise<void> {
  if (!isDatabaseConfigured()) {
    if (!mockAvailabilitySlots.delete(availabilityId)) {
      throw new Error("La disponibilidad no existe.");
    }
    return;
  }

  const result = await query(
    `
      delete from specialist_availability
      where id = $1
    `,
    [availabilityId],
  );

  if (result.rowCount === 0) {
    throw new Error("La disponibilidad no existe.");
  }
}

export async function createManagedBooking(
  input: CreateBookingInput,
  userId?: string,
): Promise<Booking> {
  const serviceId = input.serviceId?.trim();
  const specialistId = input.specialistId?.trim();
  if (!serviceId || !specialistId || !input.scheduledAt || !input.mode) {
    throw new Error("Faltan campos obligatorios para crear la reserva.");
  }

  const service = getServiceById(serviceId);
  if (!service) {
    throw new Error("El servicio no existe.");
  }

  const specialist = getSpecialistById(specialistId);
  if (!specialist) {
    throw new Error("El especialista no existe.");
  }

  if (!service.specialistIds.includes(specialist.id)) {
    throw new Error("El especialista no ofrece ese servicio.");
  }
  if (!service.deliveryModes.includes(input.mode)) {
    throw new Error("Ese servicio no admite el modo seleccionado.");
  }

  await assertBookableSlot(service, specialist, input.scheduledAt, input.mode);
  const booking = await createBookingBase(input, userId);

  await logAudit(
    "user",
    userId ?? demoUserId,
    "booking.created",
    "booking",
    booking.id,
    {
      serviceId: booking.serviceId,
      specialistId: booking.specialistId,
      scheduledAt: booking.scheduledAt,
      mode: booking.mode,
      status: booking.status,
    },
  );

  return booking;
}

export async function updateManagedBooking(
  bookingId: string,
  input: UpdateBookingInput,
  userId?: string,
): Promise<Booking> {
  const bookings = await getBookingsBase(userId);
  const existingBooking = getBookingFromCollection(bookings, bookingId);
  const policy = buildPolicy(existingBooking);

  const service = getServiceById(existingBooking.serviceId);
  if (!service) {
    throw new Error("El servicio asociado ya no existe.");
  }

  const nextMode = input.mode ?? existingBooking.mode;
  const nextScheduledAt = input.scheduledAt?.trim() || existingBooking.scheduledAt;

  if (input.status === "cancelled" && !policy.canCancel) {
    throw new Error(policy.message);
  }

  const isReschedule =
    nextScheduledAt !== existingBooking.scheduledAt || nextMode !== existingBooking.mode;
  if (isReschedule && !policy.canReschedule) {
    throw new Error(policy.message);
  }

  if (isReschedule) {
    const specialist = getSpecialistById(existingBooking.specialistId);
    if (!specialist) {
      throw new Error("El especialista asociado ya no existe.");
    }

    await assertBookableSlot(
      service,
      specialist,
      nextScheduledAt,
      nextMode,
      existingBooking.id,
    );
  }

  const updatedBooking = await updateBookingBase(bookingId, input, userId);
  if (updatedBooking.status === "cancelled") {
    await logAudit(
      "user",
      userId ?? demoUserId,
      "booking.cancelled",
      "booking",
      bookingId,
      {
        scheduledAt: existingBooking.scheduledAt,
        previousStatus: existingBooking.status,
        cancellationReason: input.cancellationReason?.trim() ?? "",
      },
    );
  } else if (isReschedule) {
    await logAudit(
      "user",
      userId ?? demoUserId,
      "booking.rescheduled",
      "booking",
      bookingId,
      {
        fromScheduledAt: existingBooking.scheduledAt,
        toScheduledAt: updatedBooking.scheduledAt,
        fromMode: existingBooking.mode,
        toMode: updatedBooking.mode,
        rescheduleReason: input.rescheduleReason?.trim() ?? "",
      },
    );
  } else {
    await logAudit(
      "user",
      userId ?? demoUserId,
      "booking.updated",
      "booking",
      bookingId,
      {
        notesChanged: input.notes !== undefined,
        status: updatedBooking.status,
      },
    );
  }

  return updatedBooking;
}

export async function getBookingPolicy(
  bookingId: string,
  userId?: string,
): Promise<BookingPolicy> {
  const bookings = await getBookingsBase(userId);
  const booking = getBookingFromCollection(bookings, bookingId);
  return buildPolicy(booking);
}

export async function getBookingHistory(
  bookingId: string,
  userId?: string,
): Promise<BookingAuditEntry[]> {
  const bookings = await getBookingsBase(userId);
  getBookingFromCollection(bookings, bookingId);

  if (!isDatabaseConfigured()) {
    return mockAuditLog.filter((item) => item.entityId === bookingId);
  }

  const result = await query<AuditRow>(
    `
      select
        id,
        actor_type,
        actor_id,
        event_type,
        entity_type,
        entity_id,
        payload,
        created_at
      from audit_logs
      where entity_type = 'booking'
        and entity_id = $1
      order by created_at desc
    `,
    [bookingId],
  );

  return result.rows.map(mapAuditRow);
}
