import type { FastifyInstance } from "fastify";

import {
  getTarotImageContent,
  listTarotImageItems,
} from "../../data/tarot-images.js";

export async function registerTarotRoutes(app: FastifyInstance) {
  app.get("/cards", async (_request, reply) => {
    try {
      return {
        items: await listTarotImageItems(),
      };
    } catch (error) {
      reply.code(500);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo listar el catálogo de cartas.",
      };
    }
  });

  app.get<{ Params: { slug: string } }>("/cards/:slug/image", async (request, reply) => {
    try {
      const image = await getTarotImageContent(request.params.slug);
      reply.header("content-type", image.contentType);
      reply.header("cache-control", "public, max-age=86400");
      reply.header(
        "content-disposition",
        `inline; filename="${image.filename.replaceAll('"', "")}"`,
      );

      return Buffer.from(image.bytes);
    } catch (error) {
      reply.code(404);
      return {
        error:
          error instanceof Error
            ? error.message
            : "No se pudo recuperar la imagen de la carta.",
      };
    }
  });
}
