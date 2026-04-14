import type { FastifyInstance } from "fastify";

import {
  createCommunityChatMessage,
  createChatMessage,
  createChatThread,
  type CreateCommunityChatMessageInput,
  type CreateChatMessageInput,
  type CreateChatThreadInput,
  getCommunityChatMessages,
  getChatThread,
  getChatThreads,
} from "../../data/chat-store.js";
import { getUserIdForAccessToken } from "../../data/persistent-store.js";
import { readAccessToken } from "../shared/auth.js";

export async function registerChatRoutes(app: FastifyInstance) {
  app.get("/community", async () => {
    return {
      items: await getCommunityChatMessages(),
    };
  });

  app.post<{ Body: CreateCommunityChatMessageInput }>(
    "/community/messages",
    async (request, reply) => {
      try {
        const accessToken = readAccessToken(request.headers.authorization);
        const userId =
          (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

        reply.code(201);
        return {
          items: await createCommunityChatMessage(request.body ?? {}, userId),
        };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudo enviar el mensaje al chat general.",
        };
      }
    },
  );

  app.get("/threads", async (request) => {
    const accessToken = readAccessToken(request.headers.authorization);
    const userId =
      (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

    return {
      items: await getChatThreads(userId),
    };
  });

  app.post<{ Body: CreateChatThreadInput }>("/threads", async (request, reply) => {
    try {
      const accessToken = readAccessToken(request.headers.authorization);
      const userId =
        (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

      reply.code(201);
      return {
        item: await createChatThread(request.body ?? {}, userId),
      };
    } catch (error) {
      reply.code(400);
      return {
        error:
          error instanceof Error ? error.message : "No se pudo crear el hilo.",
      };
    }
  });

  app.get<{ Params: { threadId: string } }>("/threads/:threadId", async (request, reply) => {
    try {
      const accessToken = readAccessToken(request.headers.authorization);
      const userId =
        (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

      return {
        item: await getChatThread(request.params.threadId, userId),
      };
    } catch (error) {
      reply.code(404);
      return {
        error:
          error instanceof Error ? error.message : "No se pudo cargar el hilo.",
      };
    }
  });

  app.post<{ Params: { threadId: string }; Body: CreateChatMessageInput }>(
    "/threads/:threadId/messages",
    async (request, reply) => {
      try {
        const accessToken = readAccessToken(request.headers.authorization);
        const userId =
          (await getUserIdForAccessToken(accessToken ?? undefined)) ?? undefined;

        reply.code(201);
        return {
          item: await createChatMessage(
            request.params.threadId,
            request.body ?? {},
            userId,
          ),
        };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error ? error.message : "No se pudo enviar el mensaje.",
        };
      }
    },
  );
}
