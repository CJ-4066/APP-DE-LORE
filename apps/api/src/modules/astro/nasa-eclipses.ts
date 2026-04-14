import * as AstronomyEngine from "astronomy-engine";

type AstronomyModule = typeof import("astronomy-engine");

const astronomy = (
  AstronomyEngine as AstronomyModule & { default?: AstronomyModule }
).default ?? AstronomyEngine;

const { DeltaT_EspenakMeeus } = astronomy;

type NasaEclipseType = "solar_eclipse_global" | "lunar_eclipse";

export interface NasaEclipseEvent {
  type: NasaEclipseType;
  label: string;
  kind: string;
  startsAt: string;
  visibility: string;
  sourceLabel: string;
  sourceUrl: string;
}

interface CachedDecadeEvents {
  expiresAt: number;
  events: NasaEclipseEvent[];
}

const nasaCache = new Map<string, CachedDecadeEvents>();
const cacheTtlMs = 12 * 60 * 60 * 1000;

export async function getUpcomingNasaEclipses(
  fromDate: Date,
): Promise<NasaEclipseEvent[]> {
  const currentDecadeStart = decadeStartForYear(fromDate.getUTCFullYear());
  const targetDecades = [currentDecadeStart, currentDecadeStart + 10];
  const decadeEvents = await Promise.all(
    targetDecades.flatMap((decadeStart) => [
      loadNasaDecadeEvents("lunar_eclipse", decadeStart),
      loadNasaDecadeEvents("solar_eclipse_global", decadeStart),
    ]),
  );

  return decadeEvents
    .flat()
    .filter((event) => new Date(event.startsAt).getTime() >= fromDate.getTime())
    .sort((left, right) => left.startsAt.localeCompare(right.startsAt));
}

async function loadNasaDecadeEvents(
  type: NasaEclipseType,
  decadeStart: number,
): Promise<NasaEclipseEvent[]> {
  const cacheKey = `${type}:${decadeStart}`;
  const cached = nasaCache.get(cacheKey);
  if (cached && cached.expiresAt > Date.now()) {
    return cached.events;
  }

  const sourceUrl =
    type === "lunar_eclipse"
      ? `https://eclipse.gsfc.nasa.gov/LEdecade/LEdecade${decadeStart}.html`
      : `https://eclipse.gsfc.nasa.gov/SEdecade/SEdecade${decadeStart}.html`;
  const response = await fetch(sourceUrl, {
    headers: {
      "user-agent": "Lo-Renaciente-Astro/1.0",
    },
  });

  if (!response.ok) {
    throw new Error(
      `NASA devolvió ${response.status} para ${type} ${decadeStart}.`,
    );
  }

  const html = await response.text();
  const events = parseNasaDecadeHtml(html, type, sourceUrl);
  nasaCache.set(cacheKey, {
    expiresAt: Date.now() + cacheTtlMs,
    events,
  });

  return events;
}

function parseNasaDecadeHtml(
  html: string,
  type: NasaEclipseType,
  sourceUrl: string,
): NasaEclipseEvent[] {
  const rows = html.match(/<tr\b[^>]*>[\s\S]*?<\/tr>/gi) ?? [];
  const events: NasaEclipseEvent[] = [];

  for (const row of rows) {
    const cells = [...row.matchAll(/<td\b[^>]*>([\s\S]*?)<\/td>/gi)].map(
      (match) => match[1],
    );
    if (cells.length < 7) {
      continue;
    }

    const dateText = normalizeText(cells[0]);
    const timeText = normalizeText(cells[1]);
    const kindText = normalizeText(cells[2]);
    const visibilityText = normalizeText(cells[6]);

    if (
      !/^\d{4}\s+[A-Z][a-z]{2}\s+\d{2}$/.test(dateText) ||
      !/^\d{2}:\d{2}:\d{2}$/.test(timeText)
    ) {
      continue;
    }

    const startsAt = toUtcIsoFromNasaTd(dateText, timeText);
    const translatedKind = translateEclipseKind(kindText);
    const label =
      type === "lunar_eclipse"
        ? `Eclipse lunar ${translatedKind.toLowerCase()}`
        : `Eclipse solar ${translatedKind.toLowerCase()}`;

    events.push({
      type,
      label,
      kind: translatedKind,
      startsAt,
      visibility: visibilityText,
      sourceLabel: "NASA GSFC Eclipse Web Site",
      sourceUrl,
    });
  }

  return events;
}

function decadeStartForYear(year: number): number {
  return Math.floor((year - 1) / 10) * 10 + 1;
}

function normalizeText(value: string): string {
  return decodeHtmlEntities(
    value
      .replace(/<br\s*\/?>/gi, " ")
      .replace(/<\/?strong>/gi, "")
      .replace(/<[^>]+>/g, " ")
      .replace(/\s+/g, " ")
      .trim(),
  );
}

function decodeHtmlEntities(value: string): string {
  return value
    .replaceAll("&nbsp;", " ")
    .replaceAll("&amp;", "&")
    .replaceAll("&quot;", '"')
    .replaceAll("&#39;", "'")
    .replaceAll("&lt;", "<")
    .replaceAll("&gt;", ">")
    .trim();
}

function translateEclipseKind(kind: string): string {
  switch (kind.toLowerCase()) {
    case "total":
      return "Total";
    case "annular":
      return "Anular";
    case "hybrid":
      return "Hibrido";
    case "partial":
      return "Parcial";
    case "penumbral":
      return "Penumbral";
    default:
      return kind;
  }
}

function toUtcIsoFromNasaTd(dateText: string, timeText: string): string {
  const [yearText, monthText, dayText] = dateText.split(/\s+/);
  const [hourText, minuteText, secondText] = timeText.split(":");
  const year = Number(yearText);
  const monthIndex = monthIndexFromAbbreviation(monthText);
  const day = Number(dayText);
  const hour = Number(hourText);
  const minute = Number(minuteText);
  const second = Number(secondText);

  const terrestrialDate = new Date(
    Date.UTC(year, monthIndex, day, hour, minute, second),
  );
  const deltaTSeconds = DeltaT_EspenakMeeus(decimalYear(terrestrialDate));
  return new Date(terrestrialDate.getTime() - deltaTSeconds * 1000).toISOString();
}

function monthIndexFromAbbreviation(month: string): number {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  const monthIndex = months.indexOf(month);
  if (monthIndex === -1) {
    throw new Error(`Mes de NASA no reconocido: ${month}.`);
  }

  return monthIndex;
}

function decimalYear(date: Date): number {
  const year = date.getUTCFullYear();
  const start = Date.UTC(year, 0, 1);
  const end = Date.UTC(year + 1, 0, 1);
  return year + (date.getTime() - start) / (end - start);
}
