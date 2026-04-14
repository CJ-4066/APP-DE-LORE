import { randomUUID } from "node:crypto";

import type { PoolClient, QueryResultRow } from "pg";

import { isDatabaseConfigured, query, withTransaction } from "../infrastructure/database.js";
import { getBookings, getProfile } from "./persistent-store.js";
import { getSpecialists } from "./mock-store.js";

const demoUserId = "user-mark";

export type ChatAuthorType = "user" | "specialist" | "system";
export type ChatThreadStatus = "open" | "closed";

export interface ChatThreadSummary {
  id: string;
  userId: string;
  specialistId: string;
  specialistName: string;
  bookingId: string | null;
  status: ChatThreadStatus;
  lastMessagePreview: string;
  lastMessageAt: string | null;
  messageCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface ChatMessage {
  id: string;
  threadId: string;
  authorType: ChatAuthorType;
  authorId: string;
  body: string;
  createdAt: string;
}

export interface CommunityChatMessage {
  id: string;
  authorName: string;
  authorRole: "member" | "guide" | "system";
  body: string;
  createdAt: string;
}

export interface ChatThreadDetail {
  thread: ChatThreadSummary;
  messages: ChatMessage[];
}

export interface CreateChatThreadInput {
  specialistId?: string;
  bookingId?: string;
  initialMessage?: string;
}

export interface CreateChatMessageInput {
  body?: string;
}

export interface CreateCommunityChatMessageInput {
  body?: string;
}

interface ThreadRow extends QueryResultRow {
  id: string;
  user_id: string;
  specialist_id: string;
  booking_id: string | null;
  status: ChatThreadStatus;
  created_at: Date | string;
  updated_at: Date | string;
  last_message_preview?: string | null;
  last_message_at?: Date | string | null;
  message_count?: string | number | null;
}

interface MessageRow extends QueryResultRow {
  id: string;
  thread_id: string;
  author_type: ChatAuthorType;
  author_id: string;
  body: string;
  created_at: Date | string;
}

interface ThreadRecord {
  id: string;
  userId: string;
  specialistId: string;
  bookingId: string | null;
  status: ChatThreadStatus;
  createdAt: string;
  updatedAt: string;
}

const mockThreads: ThreadRecord[] = [
  {
    id: "thread-demo-amaya",
    userId: demoUserId,
    specialistId: "spec-amaya",
    bookingId: "booking-1",
    status: "open",
    createdAt: "2026-03-24T15:00:00.000Z",
    updatedAt: "2026-03-24T15:06:00.000Z",
  },
];

const mockMessages: ChatMessage[] = [
  {
    id: "thread-demo-amaya-msg-1",
    threadId: "thread-demo-amaya",
    authorType: "specialist",
    authorId: "spec-amaya",
    body: "Ya revisé el motivo de tu consulta. Antes de la sesión te dejaré dos preguntas guía.",
    createdAt: "2026-03-24T15:01:00.000Z",
  },
  {
    id: "thread-demo-amaya-msg-2",
    threadId: "thread-demo-amaya",
    authorType: "user",
    authorId: demoUserId,
    body: "Perfecto, quiero enfocarme en claridad laboral y vínculos.",
    createdAt: "2026-03-24T15:06:00.000Z",
  },
];

const mockCommunityMessages: CommunityChatMessage[] = [
  {
    id: "community-msg-1",
    authorName: "Amaya Rivas",
    authorRole: "guide",
    body: "Bienvenidos al chat general. Hoy la energía está buena para compartir cómo sienten el tránsito más fuerte del día.",
    createdAt: "2026-04-06T13:00:00.000Z",
  },
  {
    id: "community-msg-2",
    authorName: "Lucía Beltrán",
    authorRole: "guide",
    body: "Si quieren, dejen una sola pregunta o sensación por mensaje para que la conversación siga clara.",
    createdAt: "2026-04-06T13:06:00.000Z",
  },
  {
    id: "community-msg-3",
    authorName: "María V.",
    authorRole: "member",
    body: "Yo hoy siento mucho movimiento mental, como si Mercurio estuviera apurando todo.",
    createdAt: "2026-04-06T13:11:00.000Z",
  },
];

function toIsoString(value: Date | string | null | undefined): string | null {
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

function buildPreview(body: string): string {
  const normalized = body.trim();
  if (normalized.length <= 90) {
    return normalized;
  }

  return `${normalized.slice(0, 87)}...`;
}

function mapThreadRow(row: ThreadRow): ChatThreadSummary {
  return {
    id: row.id,
    userId: row.user_id,
    specialistId: row.specialist_id,
    specialistName: getSpecialistName(row.specialist_id),
    bookingId: row.booking_id,
    status: row.status,
    lastMessagePreview: buildPreview(row.last_message_preview ?? ""),
    lastMessageAt: toIsoString(row.last_message_at),
    messageCount: Number(row.message_count ?? 0),
    createdAt: toIsoString(row.created_at) ?? new Date().toISOString(),
    updatedAt: toIsoString(row.updated_at) ?? new Date().toISOString(),
  };
}

function mapMessageRow(row: MessageRow): ChatMessage {
  return {
    id: row.id,
    threadId: row.thread_id,
    authorType: row.author_type,
    authorId: row.author_id,
    body: row.body,
    createdAt: toIsoString(row.created_at) ?? new Date().toISOString(),
  };
}

function buildMockThreadSummary(thread: ThreadRecord): ChatThreadSummary {
  const messages = mockMessages
    .filter((item) => item.threadId === thread.id)
    .sort((left, right) => left.createdAt.localeCompare(right.createdAt));
  const lastMessage = messages[messages.length - 1];

  return {
    id: thread.id,
    userId: thread.userId,
    specialistId: thread.specialistId,
    specialistName: getSpecialistName(thread.specialistId),
    bookingId: thread.bookingId,
    status: thread.status,
    lastMessagePreview: buildPreview(lastMessage?.body ?? ""),
    lastMessageAt: lastMessage?.createdAt ?? null,
    messageCount: messages.length,
    createdAt: thread.createdAt,
    updatedAt: thread.updatedAt,
  };
}

async function getThreadRowById(
  threadId: string,
  userId: string,
  runner?: Pick<PoolClient, "query">,
): Promise<ThreadRow | null> {
  const execute = runner ? runner.query.bind(runner) : query;
  const result = await execute<ThreadRow>(
    `
      select
        t.id,
        t.user_id,
        t.specialist_id,
        t.booking_id,
        t.status,
        t.created_at,
        t.updated_at,
        (
          select m.body
          from chat_messages m
          where m.thread_id = t.id
          order by m.created_at desc
          limit 1
        ) as last_message_preview,
        (
          select m.created_at
          from chat_messages m
          where m.thread_id = t.id
          order by m.created_at desc
          limit 1
        ) as last_message_at,
        (
          select count(*)::text
          from chat_messages m
          where m.thread_id = t.id
        ) as message_count
      from chat_threads t
      where t.id = $1
        and t.user_id = $2
      limit 1
    `,
    [threadId, userId],
  );

  return result.rows[0] ?? null;
}

async function getThreadMessages(
  threadId: string,
  runner?: Pick<PoolClient, "query">,
): Promise<ChatMessage[]> {
  const execute = runner ? runner.query.bind(runner) : query;
  const result = await execute<MessageRow>(
    `
      select id, thread_id, author_type, author_id, body, created_at
      from chat_messages
      where thread_id = $1
      order by created_at asc
    `,
    [threadId],
  );

  return result.rows.map(mapMessageRow);
}

function buildThreadDetail(thread: ChatThreadSummary, messages: ChatMessage[]): ChatThreadDetail {
  return {
    thread,
    messages,
  };
}

function ensureThreadMessage(input: CreateChatMessageInput): string {
  const body = input.body?.trim() ?? "";
  if (body.length < 1) {
    throw new Error("El mensaje no puede estar vacío.");
  }
  if (body.length > 4000) {
    throw new Error("El mensaje es demasiado largo.");
  }

  return body;
}

function ensureCommunityMessage(input: CreateCommunityChatMessageInput): string {
  const body = input.body?.trim() ?? "";
  if (body.length < 1) {
    throw new Error("El mensaje no puede estar vacío.");
  }
  if (body.length > 1200) {
    throw new Error("El mensaje es demasiado largo.");
  }

  return body;
}

function resolveCommunityAuthorName(profile: Awaited<ReturnType<typeof getProfile>>): string {
  const firstName = profile.firstName.trim();
  const lastName = profile.lastName.trim();
  const nickname = profile.nickname.trim();
  const fullName = [firstName, lastName]
    .filter((item) => item.length > 0)
    .join(" ");

  if (fullName.length > 0) {
    return fullName;
  }
  if (nickname.length > 0) {
    return nickname;
  }

  return "Miembro";
}

export async function getChatThreads(userId?: string): Promise<ChatThreadSummary[]> {
  const resolvedUserId = userId ?? demoUserId;

  if (!isDatabaseConfigured()) {
    return mockThreads
      .filter((thread) => thread.userId === resolvedUserId)
      .map(buildMockThreadSummary)
      .sort((left, right) => right.updatedAt.localeCompare(left.updatedAt));
  }

  const result = await query<ThreadRow>(
    `
      select
        t.id,
        t.user_id,
        t.specialist_id,
        t.booking_id,
        t.status,
        t.created_at,
        t.updated_at,
        (
          select m.body
          from chat_messages m
          where m.thread_id = t.id
          order by m.created_at desc
          limit 1
        ) as last_message_preview,
        (
          select m.created_at
          from chat_messages m
          where m.thread_id = t.id
          order by m.created_at desc
          limit 1
        ) as last_message_at,
        (
          select count(*)::text
          from chat_messages m
          where m.thread_id = t.id
        ) as message_count
      from chat_threads t
      where t.user_id = $1
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
    `,
    [resolvedUserId],
  );

  return result.rows.map(mapThreadRow);
}

export async function getChatThread(
  threadId: string,
  userId?: string,
): Promise<ChatThreadDetail> {
  const resolvedUserId = userId ?? demoUserId;

  if (!isDatabaseConfigured()) {
    const thread = mockThreads.find(
      (item) => item.id === threadId && item.userId === resolvedUserId,
    );
    if (!thread) {
      throw new Error("El hilo no existe.");
    }

    const messages = mockMessages
      .filter((item) => item.threadId === threadId)
      .sort((left, right) => left.createdAt.localeCompare(right.createdAt));

    return buildThreadDetail(buildMockThreadSummary(thread), messages);
  }

  const threadRow = await getThreadRowById(threadId, resolvedUserId);
  if (!threadRow) {
    throw new Error("El hilo no existe.");
  }

  return buildThreadDetail(mapThreadRow(threadRow), await getThreadMessages(threadId));
}

export async function createChatThread(
  input: CreateChatThreadInput,
  userId?: string,
): Promise<ChatThreadDetail> {
  const resolvedUserId = userId ?? demoUserId;
  const bookingId = input.bookingId?.trim() || null;
  let specialistId = input.specialistId?.trim() || "";

  if (bookingId) {
    const booking = (await getBookings(resolvedUserId)).find((item) => item.id === bookingId);
    if (!booking) {
      throw new Error("La reserva asociada no existe.");
    }
    specialistId = specialistId || booking.specialistId;
  }

  if (!specialistId) {
    throw new Error("Selecciona un especialista para abrir el chat.");
  }
  if (!getSpecialists().some((item) => item.id === specialistId)) {
    throw new Error("El especialista no existe.");
  }

  const initialMessage = input.initialMessage?.trim() ?? "";

  if (!isDatabaseConfigured()) {
    const existingThread = bookingId
      ? mockThreads.find(
          (item) =>
            item.userId === resolvedUserId &&
            item.bookingId === bookingId &&
            item.status === "open",
        )
      : undefined;

    if (existingThread) {
      return getChatThread(existingThread.id, resolvedUserId);
    }

    const thread: ThreadRecord = {
      id: randomUUID(),
      userId: resolvedUserId,
      specialistId,
      bookingId,
      status: "open",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    mockThreads.unshift(thread);

    if (initialMessage.length > 0) {
      mockMessages.push({
        id: randomUUID(),
        threadId: thread.id,
        authorType: "user",
        authorId: resolvedUserId,
        body: initialMessage,
        createdAt: new Date().toISOString(),
      });
      thread.updatedAt = new Date().toISOString();
    }

    return getChatThread(thread.id, resolvedUserId);
  }

  return withTransaction(async (client) => {
    if (bookingId) {
      const existing = await client.query<{ id: string }>(
        `
          select id
          from chat_threads
          where user_id = $1
            and booking_id = $2
            and status = 'open'
          limit 1
        `,
        [resolvedUserId, bookingId],
      );
      if (existing.rows[0]) {
        const detail = await getThreadRowById(existing.rows[0].id, resolvedUserId, client);
        if (!detail) {
          throw new Error("No se pudo recuperar el hilo existente.");
        }

        return buildThreadDetail(
          mapThreadRow(detail),
          await getThreadMessages(existing.rows[0].id, client),
        );
      }
    }

    const threadId = randomUUID();
    await client.query(
      `
        insert into chat_threads (
          id,
          user_id,
          specialist_id,
          booking_id,
          status
        ) values ($1, $2, $3, $4, 'open')
      `,
      [threadId, resolvedUserId, specialistId, bookingId],
    );

    if (initialMessage.length > 0) {
      await client.query(
        `
          insert into chat_messages (
            id,
            thread_id,
            author_type,
            author_id,
            body
          ) values ($1, $2, 'user', $3, $4)
        `,
        [randomUUID(), threadId, resolvedUserId, initialMessage],
      );
      await client.query(
        `
          update chat_threads
          set updated_at = now()
          where id = $1
        `,
        [threadId],
      );
    }

    const thread = await getThreadRowById(threadId, resolvedUserId, client);
    if (!thread) {
      throw new Error("No se pudo crear el hilo.");
    }

    return buildThreadDetail(mapThreadRow(thread), await getThreadMessages(threadId, client));
  });
}

export async function createChatMessage(
  threadId: string,
  input: CreateChatMessageInput,
  userId?: string,
): Promise<ChatThreadDetail> {
  const resolvedUserId = userId ?? demoUserId;
  const body = ensureThreadMessage(input);

  if (!isDatabaseConfigured()) {
    const thread = mockThreads.find(
      (item) => item.id === threadId && item.userId === resolvedUserId,
    );
    if (!thread) {
      throw new Error("El hilo no existe.");
    }
    if (thread.status !== "open") {
      throw new Error("El hilo ya está cerrado.");
    }

    mockMessages.push({
      id: randomUUID(),
      threadId,
      authorType: "user",
      authorId: resolvedUserId,
      body,
      createdAt: new Date().toISOString(),
    });
    thread.updatedAt = new Date().toISOString();

    return getChatThread(threadId, resolvedUserId);
  }

  return withTransaction(async (client) => {
    const thread = await getThreadRowById(threadId, resolvedUserId, client);
    if (!thread) {
      throw new Error("El hilo no existe.");
    }
    if (thread.status !== "open") {
      throw new Error("El hilo ya está cerrado.");
    }

    await client.query(
      `
        insert into chat_messages (
          id,
          thread_id,
          author_type,
          author_id,
          body
        ) values ($1, $2, 'user', $3, $4)
      `,
      [randomUUID(), threadId, resolvedUserId, body],
    );

    await client.query(
      `
        update chat_threads
        set updated_at = now()
        where id = $1
      `,
      [threadId],
    );

    const updatedThread = await getThreadRowById(threadId, resolvedUserId, client);
    if (!updatedThread) {
      throw new Error("No se pudo recuperar el hilo actualizado.");
    }

    return buildThreadDetail(
      mapThreadRow(updatedThread),
      await getThreadMessages(threadId, client),
    );
  });
}

export async function getCommunityChatMessages(): Promise<CommunityChatMessage[]> {
  return [...mockCommunityMessages].sort(
    (left, right) => left.createdAt.localeCompare(right.createdAt),
  );
}

export async function createCommunityChatMessage(
  input: CreateCommunityChatMessageInput,
  userId?: string,
): Promise<CommunityChatMessage[]> {
  const resolvedUserId = userId ?? demoUserId;
  const body = ensureCommunityMessage(input);
  const profile = await getProfile(resolvedUserId);

  mockCommunityMessages.push({
    id: randomUUID(),
    authorName: resolveCommunityAuthorName(profile),
    authorRole: "member",
    body,
    createdAt: new Date().toISOString(),
  });

  return getCommunityChatMessages();
}
