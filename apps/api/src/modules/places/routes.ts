import type { FastifyInstance } from "fastify";

interface PlacesQuerystring {
  q?: string;
  limit?: string;
}

interface OpenMeteoSearchResult {
  id?: number;
  name?: string;
  country?: string;
  admin1?: string;
  latitude?: number;
  longitude?: number;
  timezone?: string;
}

export async function registerPlaceRoutes(app: FastifyInstance) {
  app.get<{ Querystring: PlacesQuerystring }>(
    "/search",
    async (request, reply) => {
      try {
        const query = (request.query?.q ?? "").trim();
        const limit = Math.min(
          Math.max(Number(request.query?.limit ?? "8") || 8, 1),
          12,
        );

        if (query.length < 2) {
          reply.code(200);
          return { items: [] };
        }

        const items = await searchPlaces(query, limit);
        reply.code(200);
        return { items };
      } catch (error) {
        reply.code(400);
        return {
          error:
            error instanceof Error
              ? error.message
              : "No se pudieron buscar lugares.",
        };
      }
    },
  );
}

async function searchPlaces(query: string, limit: number) {
  const url = new URL("https://geocoding-api.open-meteo.com/v1/search");
  url.searchParams.set("name", query);
  url.searchParams.set("count", String(limit));
  url.searchParams.set("language", "es");
  url.searchParams.set("format", "json");

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 6000);

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        accept: "application/json",
        "user-agent": "lo-renaciente/0.1 places-search",
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      throw new Error(
        `La búsqueda de lugares devolvió ${response.status}. Intenta otra vez.`,
      );
    }

    const data = (await response.json()) as {
      results?: OpenMeteoSearchResult[];
    };
    const results = Array.isArray(data.results) ? data.results : [];

    return results
      .filter(
        (item) =>
          item.name &&
          item.country &&
          typeof item.latitude === "number" &&
          typeof item.longitude === "number" &&
          item.timezone,
      )
      .map((item) => {
        const timeZoneId = item.timezone as string;
        return {
          id: item.id ? `geo-${item.id}` : buildPlaceId(item),
          city: item.name as string,
          state: (item.admin1 ?? "").trim(),
          country: item.country as string,
          latitude: Number(item.latitude),
          longitude: Number(item.longitude),
          timeZoneId,
          utcOffset: readUtcOffsetFromTimeZone(new Date(), timeZoneId),
        };
      });
  } finally {
    clearTimeout(timeoutId);
  }
}

function buildPlaceId(item: OpenMeteoSearchResult): string {
  return [
    item.country ?? "place",
    item.admin1 ?? "",
    item.name ?? "",
  ]
    .join("-")
    .toLowerCase()
    .replaceAll(/[^a-z0-9]+/g, "-")
    .replaceAll(/^-+|-+$/g, "");
}

function readUtcOffsetFromTimeZone(date: Date, timeZoneId: string): string {
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone: timeZoneId,
    timeZoneName: "shortOffset",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  });
  const parts = formatter.formatToParts(date);
  const value = parts.find((part) => part.type === "timeZoneName")?.value ?? "";
  const match = value.match(/^GMT([+-])(\d{1,2})(?::?(\d{2}))?$/i);

  if (!match) {
    return "UTC";
  }

  const sign = match[1];
  const hour = match[2].padStart(2, "0");
  const minute = (match[3] ?? "00").padStart(2, "0");
  return `${sign}${hour}:${minute}`;
}
