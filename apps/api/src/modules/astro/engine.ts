import * as AstronomyEngine from "astronomy-engine";

import { getUpcomingNasaEclipses } from "./nasa-eclipses.js";
import { getSwissEphemeris } from "./swiss.js";

type AstronomyModule = typeof import("astronomy-engine");

const astronomy = (
  AstronomyEngine as AstronomyModule & { default?: AstronomyModule }
).default ?? AstronomyEngine;

const {
  AstroTime,
  Body,
  Ecliptic,
  EclipticGeoMoon,
  GeoVector,
  NextGlobalSolarEclipse,
  NextLunarEclipse,
  NextMoonQuarter,
  SearchGlobalSolarEclipse,
  SearchLunarEclipse,
  SearchMoonQuarter,
  SiderealTime,
  e_tilt,
} = astronomy;

type SupportedBody =
  | AstronomyEngine.Body.Sun
  | AstronomyEngine.Body.Mercury
  | AstronomyEngine.Body.Venus
  | AstronomyEngine.Body.Mars
  | AstronomyEngine.Body.Jupiter
  | AstronomyEngine.Body.Saturn
  | AstronomyEngine.Body.Uranus
  | AstronomyEngine.Body.Neptune
  | AstronomyEngine.Body.Pluto;

type PlanetKey =
  | "sun"
  | "moon"
  | "mercury"
  | "venus"
  | "mars"
  | "jupiter"
  | "saturn"
  | "uranus"
  | "neptune"
  | "pluto";

type SwissTechnicalBody =
  | "TrueNode"
  | "MeanNode"
  | "TrueLilith"
  | "MeanLilith"
  | "Chiron"
  | "Ceres"
  | "Pallas"
  | "Juno"
  | "Vesta"
  | "Pholus";
type NodeType = "true" | "mean";
type LilithType = "mean" | "true";
type ArabicPartsMode = "same" | "sect";
type TechnicalPointKey =
  | "north_node"
  | "south_node"
  | "chiron"
  | "lilith"
  | "fortune"
  | "misfortune"
  | "vertex"
  | "ceres"
  | "pallas"
  | "juno"
  | "vesta"
  | "chariklo"
  | "eros"
  | "eris"
  | "icarus"
  | "nessus"
  | "pholus"
  | "psyche";

interface ZodiacSignDefinition {
  index: number;
  name: string;
  element: "Fuego" | "Tierra" | "Aire" | "Agua";
  quality: "Cardinal" | "Fijo" | "Mutable";
  ruler: string;
  keyword: string;
}

interface PlanetDefinition {
  key: PlanetKey;
  body: SupportedBody | "Moon";
  label: string;
}

interface AspectPoint {
  label: string;
  displayLabel: string;
  longitude: number;
  category: "planet" | "angle";
}

interface AspectDefinition {
  type: AstroAspect["type"];
  angle: number;
  baseOrb: number;
}

type HouseSystem = "placidus" | "whole_sign" | "equal";

interface ParsedNatalInput {
  birthDateTimeUtc: Date;
  normalizedBirthDate: string;
  normalizedBirthTime: string;
  birthTimeUnknown: boolean;
  utcOffset: string;
  timeZoneId: string;
  selectedPlanets: PlanetKey[];
  nodeType: NodeType;
  lilithType: LilithType;
  arabicPartsMode: ArabicPartsMode;
  technicalPoints: TechnicalPointKey[];
  latitude: number;
  longitude: number;
  locationLabel: string;
  houseSystem: HouseSystem;
  subjectName: string;
}

interface HouseCalculationContext {
  houseSystem: HouseSystem;
  ascendantLongitude: number;
  ascendantSignIndex: number;
  houseCusps?: number[];
}

interface NatalContext {
  parsed: ParsedNatalInput;
  ephemerisSource: "swisseph" | "moshier" | "astronomy-engine";
  planets: AstroPlacement[];
  points: AstroPlacement[];
  sun: AstroPlacement;
  moon: AstroPlacement;
  ascendant: AstroAnglePoint;
  midheaven: AstroAnglePoint;
  houses: AstroHouse[];
  aspects: AstroAspect[];
  summary: NatalChartResult["summary"];
  computedTechnicalPoints: TechnicalPointKey[];
  unsupportedTechnicalPoints: TechnicalPointKey[];
}

export interface NatalChartInput {
  subjectName?: string;
  birthDate?: string;
  birthTime?: string;
  birthTimeUnknown?: boolean;
  utcOffset?: string;
  timeZoneId?: string;
  selectedPlanets?: PlanetKey[];
  nodeType?: NodeType;
  lilithType?: LilithType;
  arabicPartsMode?: ArabicPartsMode;
  technicalPoints?: TechnicalPointKey[];
  latitude?: number;
  longitude?: number;
  locationLabel?: string;
  houseSystem?: HouseSystem;
}

export interface AstroPlacement {
  key: string;
  label: string;
  longitude: number;
  latitude: number;
  sign: string;
  signIndex: number;
  degreeInSign: number;
  degreeFormatted: string;
  house: number;
  retrograde: boolean;
}

export interface AstroAnglePoint {
  key: "ascendant" | "midheaven";
  label: string;
  longitude: number;
  sign: string;
  signIndex: number;
  degreeInSign: number;
  degreeFormatted: string;
  house: number;
  ruler: string;
}

export interface AstroHouse {
  number: number;
  sign: string;
  signIndex: number;
  cuspLongitude: number;
  cuspDegreeFormatted: string;
  ruler: string;
}

export interface AstroAspect {
  type: "Conjuncion" | "Sextil" | "Cuadratura" | "Trigono" | "Oposicion";
  exactAngle: number;
  orb: number;
  maxOrb: number;
  precision: "cerrado" | "moderado" | "amplio";
  left: string;
  right: string;
}

export interface NatalChartResult {
  meta: {
    engine: string;
    version: string;
    computedAt: string;
    birthDateTimeUtc: string;
    birthDate: string;
    birthTime: string;
    timeAccuracy: "exact" | "unknown";
    subjectName: string;
    utcOffset: string;
    timeZoneId: string;
    selectedPlanets: PlanetKey[];
    nodeType: NodeType;
    lilithType: LilithType;
    arabicPartsMode: ArabicPartsMode;
    technicalPoints: TechnicalPointKey[];
    computedTechnicalPoints: TechnicalPointKey[];
    unsupportedTechnicalPoints: TechnicalPointKey[];
    ephemerisSource: "swisseph" | "moshier" | "astronomy-engine";
    locationLabel: string;
    coordinates: {
      latitude: number;
      longitude: number;
    };
    houseSystem: HouseSystem;
  };
  bigThree: {
    sun: AstroPlacement;
    moon: AstroPlacement;
    ascendant: AstroAnglePoint;
  };
  angles: {
    ascendant: AstroAnglePoint;
    midheaven: AstroAnglePoint;
  };
  planets: AstroPlacement[];
  points: AstroPlacement[];
  houses: AstroHouse[];
  aspects: AstroAspect[];
  summary: {
    chartRuler: string;
    dominantElement: string;
    dominantQuality: string;
    solarSign: string;
    lunarSign: string;
    ascendantSign: string;
  };
  interpretation: string[];
}

export interface AstroEventsInput {
  from?: string;
  latitude?: number;
  longitude?: number;
}

export interface AstroUtcOffsetInput {
  birthDate?: string;
  birthTime?: string;
  birthTimeUnknown?: boolean;
  timeZoneId?: string;
}

export interface AstroUtcOffsetResult {
  meta: {
    engine: string;
    version: string;
    computedAt: string;
  };
  timeZoneId: string;
  utcOffset: string;
  birthDate: string;
  birthTime: string;
  timeAccuracy: "exact" | "unknown";
}

export interface AstroTransitsInput extends NatalChartInput {
  targetDate?: string;
}

export interface AstroTransitWindow {
  transitLabel: string;
  natalLabel: string;
  type: AstroAspect["type"];
  startsAt: string;
  endsAt: string;
}

export interface AstroTransitsResult {
  meta: {
    engine: string;
    version: string;
    computedAt: string;
    targetDateUtc: string;
    houseSystem: HouseSystem;
  };
  transits: AstroPlacement[];
  aspectsToNatal: AstroAspect[];
  highlights: string[];
  activeWindow?: AstroTransitWindow;
}

export interface AstroReturnsInput extends NatalChartInput {
  from?: string;
}

export interface AstroReturnsResult {
  meta: {
    engine: string;
    version: string;
    computedAt: string;
    from: string;
  };
  solarReturn: {
    startsAt: string;
    sunDegree: string;
  };
  lunarReturn: {
    startsAt: string;
    moonDegree: string;
  };
}

export interface AstroSynastryInput {
  left?: NatalChartInput;
  right?: NatalChartInput;
}

export interface AstroSynastryResult {
  meta: {
    engine: string;
    version: string;
    computedAt: string;
    houseSystemLeft: HouseSystem;
    houseSystemRight: HouseSystem;
  };
  left: {
    bigThree: NatalChartResult["bigThree"];
    summary: NatalChartResult["summary"];
  };
  right: {
    bigThree: NatalChartResult["bigThree"];
    summary: NatalChartResult["summary"];
  };
  crossAspects: AstroAspect[];
  highlights: string[];
}

export interface AstroEventItem {
  type:
    | "moon_phase"
    | "solar_eclipse_global"
    | "solar_eclipse_local"
    | "lunar_eclipse";
  label: string;
  kind: string;
  startsAt: string;
  visibility?: string;
  coordinates?: {
    latitude: number;
    longitude: number;
  };
  sourceLabel?: string;
  sourceUrl?: string;
}

export interface AstroEventsResult {
  meta: {
    engine: string;
    version: string;
    computedAt: string;
    from: string;
  };
  moonPhases: AstroEventItem[];
  eclipses: AstroEventItem[];
}

const zodiacSigns: ZodiacSignDefinition[] = [
  {
    index: 0,
    name: "Aries",
    element: "Fuego",
    quality: "Cardinal",
    ruler: "Marte",
    keyword: "impulso y comienzo",
  },
  {
    index: 1,
    name: "Tauro",
    element: "Tierra",
    quality: "Fijo",
    ruler: "Venus",
    keyword: "estabilidad y valor",
  },
  {
    index: 2,
    name: "Geminis",
    element: "Aire",
    quality: "Mutable",
    ruler: "Mercurio",
    keyword: "curiosidad y movimiento",
  },
  {
    index: 3,
    name: "Cancer",
    element: "Agua",
    quality: "Cardinal",
    ruler: "Luna",
    keyword: "cuidado y memoria",
  },
  {
    index: 4,
    name: "Leo",
    element: "Fuego",
    quality: "Fijo",
    ruler: "Sol",
    keyword: "expresion y presencia",
  },
  {
    index: 5,
    name: "Virgo",
    element: "Tierra",
    quality: "Mutable",
    ruler: "Mercurio",
    keyword: "orden y mejora",
  },
  {
    index: 6,
    name: "Libra",
    element: "Aire",
    quality: "Cardinal",
    ruler: "Venus",
    keyword: "vinculo y equilibrio",
  },
  {
    index: 7,
    name: "Escorpio",
    element: "Agua",
    quality: "Fijo",
    ruler: "Pluton",
    keyword: "intensidad y transformación",
  },
  {
    index: 8,
    name: "Sagitario",
    element: "Fuego",
    quality: "Mutable",
    ruler: "Jupiter",
    keyword: "sentido y expansión",
  },
  {
    index: 9,
    name: "Capricornio",
    element: "Tierra",
    quality: "Cardinal",
    ruler: "Saturno",
    keyword: "estructura y logro",
  },
  {
    index: 10,
    name: "Acuario",
    element: "Aire",
    quality: "Fijo",
    ruler: "Urano",
    keyword: "vision y diferencia",
  },
  {
    index: 11,
    name: "Piscis",
    element: "Agua",
    quality: "Mutable",
    ruler: "Neptuno",
    keyword: "sensibilidad e imaginación",
  },
];

const planets: PlanetDefinition[] = [
  { key: "sun", body: Body.Sun, label: "Sol" },
  { key: "moon", body: "Moon", label: "Luna" },
  { key: "mercury", body: Body.Mercury, label: "Mercurio" },
  { key: "venus", body: Body.Venus, label: "Venus" },
  { key: "mars", body: Body.Mars, label: "Marte" },
  { key: "jupiter", body: Body.Jupiter, label: "Jupiter" },
  { key: "saturn", body: Body.Saturn, label: "Saturno" },
  { key: "uranus", body: Body.Uranus, label: "Urano" },
  { key: "neptune", body: Body.Neptune, label: "Neptuno" },
  { key: "pluto", body: Body.Pluto, label: "Pluton" },
];

const defaultSelectedPlanets: PlanetKey[] = planets.map((planet) => planet.key);

const defaultTechnicalPoints: TechnicalPointKey[] = [
  "north_node",
  "south_node",
  "chiron",
  "lilith",
  "fortune",
  "vertex",
];

const engineName = "lo-renaciente-astro-engine";
const engineVersion = "0.6.0";

const aspectDefinitions: AspectDefinition[] = [
  { type: "Conjuncion", angle: 0, baseOrb: 8 },
  { type: "Sextil", angle: 60, baseOrb: 4.5 },
  { type: "Cuadratura", angle: 90, baseOrb: 6 },
  { type: "Trigono", angle: 120, baseOrb: 6 },
  { type: "Oposicion", angle: 180, baseOrb: 8 },
];

export async function calculateNatalChart(
  input: NatalChartInput,
): Promise<NatalChartResult> {
  const natal = await buildNatalContext(input);

  return {
    meta: {
      engine: engineName,
      version: engineVersion,
      computedAt: new Date().toISOString(),
      birthDateTimeUtc: natal.parsed.birthDateTimeUtc.toISOString(),
      birthDate: natal.parsed.normalizedBirthDate,
      birthTime: natal.parsed.normalizedBirthTime,
      timeAccuracy: natal.parsed.birthTimeUnknown ? "unknown" : "exact",
      subjectName: natal.parsed.subjectName,
      utcOffset: natal.parsed.utcOffset,
      timeZoneId: natal.parsed.timeZoneId,
      selectedPlanets: natal.parsed.selectedPlanets,
      nodeType: natal.parsed.nodeType,
      lilithType: natal.parsed.lilithType,
      arabicPartsMode: natal.parsed.arabicPartsMode,
      technicalPoints: natal.parsed.technicalPoints,
      computedTechnicalPoints: natal.computedTechnicalPoints,
      unsupportedTechnicalPoints: natal.unsupportedTechnicalPoints,
      ephemerisSource: natal.ephemerisSource,
      locationLabel: natal.parsed.locationLabel,
      coordinates: {
        latitude: natal.parsed.latitude,
        longitude: natal.parsed.longitude,
      },
      houseSystem: natal.parsed.houseSystem,
    },
    bigThree: {
      sun: natal.sun,
      moon: natal.moon,
      ascendant: natal.ascendant,
    },
    angles: {
      ascendant: natal.ascendant,
      midheaven: natal.midheaven,
    },
    planets: natal.planets,
    points: natal.points,
    houses: natal.houses,
    aspects: natal.aspects,
    summary: natal.summary,
    interpretation: buildInterpretation({
      sun: natal.sun,
      moon: natal.moon,
      ascendant: natal.ascendant,
      summary: natal.summary,
    }),
  };
}

export function calculateHistoricalUtcOffset(
  input: AstroUtcOffsetInput,
): AstroUtcOffsetResult {
  const birthDate = normalizeBirthDateInput((input.birthDate ?? "").trim());
  const birthTime = normalizeBirthTimeInput(
    (input.birthTime ?? "").trim(),
    Boolean(input.birthTimeUnknown),
  );
  const timeZoneId = (input.timeZoneId ?? "").trim();

  if (!/^\d{4}-\d{2}-\d{2}$/.test(birthDate)) {
    throw new Error("birthDate debe tener formato YYYY-MM-DD o DD-MM-YYYY.");
  }

  if (!birthTime) {
    throw new Error(
      "birthTime debe tener formato HH:MM, HH:MM:SS o marcar hora desconocida.",
    );
  }

  if (!timeZoneId) {
    throw new Error("timeZoneId es requerido para resolver el UTC offset.");
  }

  const utcOffset = resolveUtcOffsetForLocalDateTime(
    birthDate,
    birthTime,
    timeZoneId,
  );

  return {
    meta: {
      engine: engineName,
      version: engineVersion,
      computedAt: new Date().toISOString(),
    },
    timeZoneId,
    utcOffset,
    birthDate,
    birthTime,
    timeAccuracy: input.birthTimeUnknown ? "unknown" : "exact",
  };
}

export async function calculateTransits(
  input: AstroTransitsInput,
): Promise<AstroTransitsResult> {
  const natal = await buildNatalContext(input);
  const targetDate = parseTargetDate(input.targetDate);
  const houseContext = createHouseCalculationContext(
    natal.parsed.houseSystem,
    natal.ascendant.longitude,
    natal.ascendant.signIndex,
    natal.houses.map((house) => house.cuspLongitude),
  );
  const allTransits =
    natal.parsed.houseSystem === "placidus"
      ? await buildSwissPlacements(targetDate, houseContext)
      : planets.map((planet) =>
          buildPlacement(planet.label, planet.body, targetDate, houseContext),
        );
  const transits = filterSelectedPlanets(allTransits, natal.parsed.selectedPlanets);
  const aspectsToNatal = buildCrossAspects(transits, natal.planets);
  const activeWindow = await buildActiveTransitWindow({
    aspectsToNatal,
    natalPlacements: natal.planets,
    targetDate,
    houseSystem: natal.parsed.houseSystem,
    houseContext,
  });

  return {
    meta: {
      engine: engineName,
      version: engineVersion,
      computedAt: new Date().toISOString(),
      targetDateUtc: targetDate.toISOString(),
      houseSystem: natal.parsed.houseSystem,
    },
    transits,
    aspectsToNatal,
    highlights: buildTransitHighlights(aspectsToNatal),
    activeWindow,
  };
}

export async function calculateNextReturns(
  input: AstroReturnsInput,
): Promise<AstroReturnsResult> {
  const natal = await buildNatalContext(input);
  const fromDate = parseEventsStartDate(input.from);
  const [solarReturn, lunarReturn] = await Promise.all([
    searchNextLongitudeReturn(Body.Sun, natal.sun.longitude, fromDate),
    searchNextLongitudeReturn("Moon", natal.moon.longitude, fromDate),
  ]);

  if (!solarReturn || !lunarReturn) {
    throw new Error("No se pudieron calcular las revoluciones pedidas.");
  }

  return {
    meta: {
      engine: engineName,
      version: engineVersion,
      computedAt: new Date().toISOString(),
      from: fromDate.toISOString(),
    },
    solarReturn: {
      startsAt: solarReturn.date.toISOString(),
      sunDegree: natal.sun.degreeFormatted,
    },
    lunarReturn: {
      startsAt: lunarReturn.date.toISOString(),
      moonDegree: natal.moon.degreeFormatted,
    },
  };
}

export async function calculateSynastry(
  input: AstroSynastryInput,
): Promise<AstroSynastryResult> {
  const leftInput = input.left ?? {};
  const rightInput = input.right ?? {};
  const [left, right] = await Promise.all([
    buildNatalContext(leftInput),
    buildNatalContext(rightInput),
  ]);
  const crossAspects = buildSynastryAspects(left.planets, right.planets);

  return {
    meta: {
      engine: engineName,
      version: engineVersion,
      computedAt: new Date().toISOString(),
      houseSystemLeft: left.parsed.houseSystem,
      houseSystemRight: right.parsed.houseSystem,
    },
    left: {
      bigThree: {
        sun: left.sun,
        moon: left.moon,
        ascendant: left.ascendant,
      },
      summary: left.summary,
    },
    right: {
      bigThree: {
        sun: right.sun,
        moon: right.moon,
        ascendant: right.ascendant,
      },
      summary: right.summary,
    },
    crossAspects,
    highlights: crossAspects.slice(0, 6).map((aspect) => {
      return `${aspect.left} hace ${aspect.type} con ${aspect.right} (orb ${aspect.orb}°).`;
    }),
  };
}

export async function getUpcomingAstroEvents(
  input: AstroEventsInput = {},
): Promise<AstroEventsResult> {
  const fromDate = parseEventsStartDate(input.from);
  const moonPhases = buildMoonPhaseEvents(fromDate);
  const eclipses = await buildEclipseEvents(
    fromDate,
    input.latitude,
    input.longitude,
  );

  return {
    meta: {
      engine: engineName,
      version: engineVersion,
      computedAt: new Date().toISOString(),
      from: fromDate.toISOString(),
    },
    moonPhases,
    eclipses,
  };
}

function parseNatalInput(input: NatalChartInput): ParsedNatalInput {
  const birthDate = (input.birthDate ?? "").trim();
  const birthTime = (input.birthTime ?? "").trim();
  const birthTimeUnknown = Boolean(input.birthTimeUnknown);
  const inputUtcOffset = (input.utcOffset ?? "").trim();
  const timeZoneId = (input.timeZoneId ?? "").trim();
  const selectedPlanets = normalizeSelectedPlanets(input.selectedPlanets);
  const nodeType = normalizeNodeType(input.nodeType);
  const lilithType = normalizeLilithType(input.lilithType);
  const arabicPartsMode = normalizeArabicPartsMode(input.arabicPartsMode);
  const technicalPoints = normalizeTechnicalPoints(input.technicalPoints);
  const latitude = Number(input.latitude);
  const longitude = Number(input.longitude);
  const locationLabel = (input.locationLabel ?? "").trim() || "Ubicación natal";
  const subjectName = (input.subjectName ?? "").trim();
  const houseSystem = (input.houseSystem ?? "placidus").trim() as HouseSystem;
  const normalizedBirthDate = normalizeBirthDateInput(birthDate);
  const normalizedBirthTime = normalizeBirthTimeInput(
    birthTime,
    birthTimeUnknown,
  );
  const utcOffset =
    timeZoneId.length > 0 && normalizedBirthTime
      ? resolveUtcOffsetForLocalDateTime(
          normalizedBirthDate,
          normalizedBirthTime,
          timeZoneId,
        )
      : inputUtcOffset;

  if (!/^\d{4}-\d{2}-\d{2}$/.test(normalizedBirthDate)) {
    throw new Error("birthDate debe tener formato YYYY-MM-DD o DD-MM-YYYY.");
  }

  if (!normalizedBirthTime) {
    throw new Error(
      "birthTime debe tener formato HH:MM, HH:MM:SS o marcar hora desconocida.",
    );
  }

  if (!/^[+-]\d{2}:\d{2}$/.test(utcOffset)) {
    throw new Error(
      "utcOffset debe tener formato +/-HH:MM o debes indicar un timeZoneId válido.",
    );
  }

  if (!Number.isFinite(latitude) || latitude < -90 || latitude > 90) {
    throw new Error("latitude debe estar entre -90 y 90.");
  }

  if (!Number.isFinite(longitude) || longitude < -180 || longitude > 180) {
    throw new Error("longitude debe estar entre -180 y 180.");
  }

  if (
    houseSystem !== "placidus" &&
    houseSystem !== "whole_sign" &&
    houseSystem !== "equal"
  ) {
    throw new Error("houseSystem debe ser placidus, whole_sign o equal.");
  }

  const birthDateTimeUtc = new Date(
    `${normalizedBirthDate}T${normalizedBirthTime}${utcOffset}`,
  );
  if (Number.isNaN(birthDateTimeUtc.getTime())) {
    throw new Error("No se pudo interpretar la fecha y hora natal.");
  }

  return {
    birthDateTimeUtc,
    normalizedBirthDate,
    normalizedBirthTime,
    birthTimeUnknown,
    utcOffset,
    timeZoneId,
    selectedPlanets,
    nodeType,
    lilithType,
    arabicPartsMode,
    technicalPoints,
    latitude,
    longitude,
    locationLabel,
    houseSystem,
    subjectName,
  };
}

function parseTargetDate(raw?: string): Date {
  if (!raw) {
    return new Date();
  }

  const parsed = new Date(raw);
  if (Number.isNaN(parsed.getTime())) {
    throw new Error("targetDate debe ser una fecha ISO válida.");
  }

  return parsed;
}

function parseEventsStartDate(raw?: string): Date {
  if (!raw) {
    return new Date();
  }

  const parsed = new Date(raw);
  if (Number.isNaN(parsed.getTime())) {
    throw new Error("from debe ser una fecha ISO válida.");
  }

  return parsed;
}

function normalizeNodeType(raw?: string): NodeType {
  return raw === "mean" ? "mean" : "true";
}

function normalizeLilithType(raw?: string): LilithType {
  return raw === "true" ? "true" : "mean";
}

function normalizeArabicPartsMode(raw?: string): ArabicPartsMode {
  return raw === "same" ? "same" : "sect";
}

function normalizeSelectedPlanets(raw?: PlanetKey[]): PlanetKey[] {
  const source =
    Array.isArray(raw) && raw.length > 0 ? raw : defaultSelectedPlanets;
  const valid = new Set<PlanetKey>(defaultSelectedPlanets);
  const normalized = source.filter((item): item is PlanetKey => valid.has(item));

  return normalized.length > 0
    ? [...new Set(normalized)]
    : [...defaultSelectedPlanets];
}

function normalizeTechnicalPoints(
  raw?: TechnicalPointKey[],
): TechnicalPointKey[] {
  const validTechnicalPoints: TechnicalPointKey[] = [
    "north_node",
    "south_node",
    "chiron",
    "lilith",
    "fortune",
    "misfortune",
    "vertex",
    "ceres",
    "pallas",
    "juno",
    "vesta",
    "chariklo",
    "eros",
    "eris",
    "icarus",
    "nessus",
    "pholus",
    "psyche",
  ];
  const source =
    Array.isArray(raw) && raw.length > 0 ? raw : defaultTechnicalPoints;
  const valid = new Set<TechnicalPointKey>(validTechnicalPoints);
  const normalized = source.filter((item): item is TechnicalPointKey =>
    valid.has(item),
  );

  return normalized.length > 0
    ? [...new Set(normalized)]
    : [...defaultTechnicalPoints];
}

function normalizeBirthDateInput(value: string): string {
  const isoMatch = value.match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (isoMatch) {
    return value;
  }

  const dayFirstMatch = value.match(/^(\d{2})-(\d{2})-(\d{4})$/);
  if (dayFirstMatch) {
    return `${dayFirstMatch[3]}-${dayFirstMatch[2]}-${dayFirstMatch[1]}`;
  }

  return value;
}

function normalizeBirthTimeInput(
  value: string,
  birthTimeUnknown: boolean,
): string | null {
  if (birthTimeUnknown) {
    return "12:00:00";
  }

  const shortMatch = value.match(/^(\d{2}):(\d{2})$/);
  if (shortMatch) {
    return `${shortMatch[1]}:${shortMatch[2]}:00`;
  }

  const longMatch = value.match(/^(\d{2}):(\d{2}):(\d{2})$/);
  if (longMatch) {
    return value;
  }

  return null;
}

function resolveUtcOffsetForLocalDateTime(
  normalizedBirthDate: string,
  normalizedBirthTime: string,
  timeZoneId: string,
): string {
  const [yearText, monthText, dayText] = normalizedBirthDate.split("-");
  const [hourText, minuteText, secondText] = normalizedBirthTime.split(":");
  const year = Number(yearText);
  const month = Number(monthText);
  const day = Number(dayText);
  const hour = Number(hourText);
  const minute = Number(minuteText);
  const second = Number(secondText);

  let utcGuess = new Date(Date.UTC(year, month - 1, day, hour, minute, second));

  for (let index = 0; index < 3; index += 1) {
    const nextOffset = readUtcOffsetFromTimeZone(utcGuess, timeZoneId);
    const nextUtc = new Date(
      Date.UTC(year, month - 1, day, hour, minute, second) -
        offsetStringToMinutes(nextOffset) * 60 * 1000,
    );
    if (nextUtc.getTime() === utcGuess.getTime()) {
      return nextOffset;
    }
    utcGuess = nextUtc;
  }

  return readUtcOffsetFromTimeZone(utcGuess, timeZoneId);
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
    throw new Error(`No se pudo resolver el UTC offset para ${timeZoneId}.`);
  }

  const sign = match[1];
  const hour = match[2].padStart(2, "0");
  const minute = (match[3] ?? "00").padStart(2, "0");
  return `${sign}${hour}:${minute}`;
}

function offsetStringToMinutes(value: string): number {
  const match = value.match(/^([+-])(\d{2}):(\d{2})$/);
  if (!match) {
    throw new Error(`UTC offset inválido: ${value}`);
  }

  const sign = match[1] === "-" ? -1 : 1;
  const hours = Number(match[2]);
  const minutes = Number(match[3]);
  return sign * (hours * 60 + minutes);
}

async function buildNatalContext(input: NatalChartInput): Promise<NatalContext> {
  const parsed = parseNatalInput(input);

  if (parsed.houseSystem === "placidus") {
    return buildSwissNatalContext(parsed);
  }

  return buildAstronomyNatalContext(parsed);
}

async function buildAstronomyNatalContext(
  parsed: ParsedNatalInput,
): Promise<NatalContext> {
  const ascendantLongitude = calculateAscendantLongitude(
    parsed.birthDateTimeUtc,
    parsed.latitude,
    parsed.longitude,
  );
  const midheavenLongitude = calculateMidheavenLongitude(
    parsed.birthDateTimeUtc,
    parsed.longitude,
  );
  const ascendantSign = getZodiacSign(ascendantLongitude);
  const houseContext = createHouseCalculationContext(
    parsed.houseSystem,
    ascendantLongitude,
    ascendantSign.index,
  );
  const placements = planets.map((planet) =>
    buildPlacement(
      planet.label,
      planet.body,
      parsed.birthDateTimeUtc,
      houseContext,
    ),
  );
  const visiblePlanets = filterSelectedPlanets(placements, parsed.selectedPlanets);
  const sun = placements.find((item) => item.key === "sol");
  const moon = placements.find((item) => item.key === "luna");

  if (!sun || !moon) {
    throw new Error("No se pudieron calcular Sol y Luna para la carta.");
  }

  const ascendant = buildAnglePoint(
    "ascendant",
    "Ascendente",
    ascendantLongitude,
    houseContext,
  );
  const midheaven = buildAnglePoint(
    "midheaven",
    "Medio Cielo",
    midheavenLongitude,
    houseContext,
  );
  const technicalPointResult = await buildConfiguredTechnicalPoints({
    parsed,
    houseContext,
    julianDayUtc: parsed.birthDateTimeUtc,
    placements,
    sun,
    moon,
    ascendant,
  });
  const houses = buildHouses(houseContext);
  const aspects = buildAspects(visiblePlanets, [ascendant, midheaven]);
  const summary = buildSummary(placements, ascendant);

  return {
    parsed,
    ephemerisSource: "astronomy-engine",
    planets: visiblePlanets,
    points: technicalPointResult.points,
    sun,
    moon,
    ascendant,
    midheaven,
    houses,
    aspects,
    summary,
    computedTechnicalPoints: technicalPointResult.computedKeys,
    unsupportedTechnicalPoints: technicalPointResult.unsupportedKeys,
  };
}

async function buildSwissNatalContext(
  parsed: ParsedNatalInput,
): Promise<NatalContext> {
  const swiss = await getSwissEphemeris();
  const julianDayUtc = toJulianDayUtc(parsed.birthDateTimeUtc, swiss.swe);
  const housesData = swiss.swe.swe_houses(
    julianDayUtc,
    parsed.latitude,
    parsed.longitude,
    "P",
  );
  const houseCusps = housesData.cusps.slice(1, 13).map((value) =>
    normalizeDegrees(value),
  );
  const ascendantLongitude = normalizeDegrees(housesData.ascmc[0]);
  const midheavenLongitude = normalizeDegrees(housesData.ascmc[1]);
  const ascendantSign = getZodiacSign(ascendantLongitude);
  const houseContext = createHouseCalculationContext(
    parsed.houseSystem,
    ascendantLongitude,
    ascendantSign.index,
    houseCusps,
  );
  const placements = await buildSwissPlacements(julianDayUtc, houseContext);
  const visiblePlanets = filterSelectedPlanets(placements, parsed.selectedPlanets);
  const sun = placements.find((item) => item.key === "sol");
  const moon = placements.find((item) => item.key === "luna");

  if (!sun || !moon) {
    throw new Error("No se pudieron calcular Sol y Luna para la carta.");
  }

  const ascendant = buildAnglePoint(
    "ascendant",
    "Ascendente",
    ascendantLongitude,
    houseContext,
  );
  const midheaven = buildAnglePoint(
    "midheaven",
    "Medio Cielo",
    midheavenLongitude,
    houseContext,
  );
  const vertexLongitude = normalizeDegrees(housesData.ascmc[3]);
  const technicalPointResult = await buildConfiguredTechnicalPoints({
    parsed,
    houseContext,
    julianDayUtc,
    placements,
    sun,
    moon,
    ascendant,
    vertexLongitude,
  });
  const houses = buildHouses(houseContext);
  const aspects = buildAspects(visiblePlanets, [ascendant, midheaven]);
  const summary = buildSummary(placements, ascendant);

  return {
    parsed,
    ephemerisSource: swiss.source,
    planets: visiblePlanets,
    points: technicalPointResult.points,
    sun,
    moon,
    ascendant,
    midheaven,
    houses,
    aspects,
    summary,
    computedTechnicalPoints: technicalPointResult.computedKeys,
    unsupportedTechnicalPoints: technicalPointResult.unsupportedKeys,
  };
}

async function buildSwissPlacements(
  julianDayUtc: number | Date,
  houseContext: HouseCalculationContext,
): Promise<AstroPlacement[]> {
  const swiss = await getSwissEphemeris();
  const resolvedJulianDay =
    julianDayUtc instanceof Date
      ? toJulianDayUtc(julianDayUtc, swiss.swe)
      : julianDayUtc;

  return planets.map((planet) =>
    buildSwissPlacement(
      planet.label,
      planet.body,
      resolvedJulianDay,
      houseContext,
      swiss.swe,
      swiss.calculationFlags,
    ),
  );
}

function buildSwissPlacement(
  label: string,
  body: SupportedBody | "Moon" | SwissTechnicalBody,
  julianDayUtc: number,
  houseContext: HouseCalculationContext,
  swe: Awaited<ReturnType<typeof getSwissEphemeris>>["swe"],
  calculationFlags: number,
  keyOverride?: string,
): AstroPlacement {
  const coordinates = swe.swe_calc_ut(
    julianDayUtc,
    mapSwissBody(body, swe),
    calculationFlags,
  );
  const longitude = normalizeDegrees(coordinates[0]);
  const latitude = coordinates[1];
  const sign = getZodiacSign(longitude);

  return {
    key: keyOverride ?? normalizeKey(label),
    label,
    longitude,
    latitude,
    sign: sign.name,
    signIndex: sign.index,
    degreeInSign: roundTo(longitude % 30, 4),
    degreeFormatted: formatDegreeInSign(longitude, sign.name),
    house: calculateHouseNumber(longitude, houseContext),
    retrograde:
      body === Body.Sun || body === "Moon" ? false : coordinates[3] < 0,
  };
}

function buildSwissAsteroidPlacement(
  label: string,
  asteroidNumber: number,
  julianDayUtc: number,
  houseContext: HouseCalculationContext,
  swe: Awaited<ReturnType<typeof getSwissEphemeris>>["swe"],
  calculationFlags: number,
  keyOverride?: string,
): AstroPlacement {
  const coordinates = swe.swe_calc_ut(
    julianDayUtc,
    swe.SE_AST_OFFSET + asteroidNumber,
    calculationFlags,
  );
  const longitude = normalizeDegrees(coordinates[0]);
  const latitude = coordinates[1];
  const sign = getZodiacSign(longitude);

  return {
    key: keyOverride ?? normalizeKey(label),
    label,
    longitude,
    latitude,
    sign: sign.name,
    signIndex: sign.index,
    degreeInSign: roundTo(longitude % 30, 4),
    degreeFormatted: formatDegreeInSign(longitude, sign.name),
    house: calculateHouseNumber(longitude, houseContext),
    retrograde: coordinates[3] < 0,
  };
}

async function buildConfiguredTechnicalPoints({
  parsed,
  houseContext,
  julianDayUtc,
  placements,
  sun,
  moon,
  ascendant,
  vertexLongitude,
}: {
  parsed: ParsedNatalInput;
  houseContext: HouseCalculationContext;
  julianDayUtc: number | Date;
  placements: AstroPlacement[];
  sun: AstroPlacement;
  moon: AstroPlacement;
  ascendant: AstroAnglePoint;
  vertexLongitude?: number;
}): Promise<{
  points: AstroPlacement[];
  computedKeys: TechnicalPointKey[];
  unsupportedKeys: TechnicalPointKey[];
}> {
  const swiss = await getSwissEphemeris();
  const resolvedJulianDay =
    julianDayUtc instanceof Date
      ? toJulianDayUtc(julianDayUtc, swiss.swe)
      : julianDayUtc;

  const points: AstroPlacement[] = [];
  const computedKeys: TechnicalPointKey[] = [];
  const unsupportedKeys: TechnicalPointKey[] = [];
  const mars = placements.find((item) => item.key === "marte");
  const saturn = placements.find((item) => item.key === "saturno");

  for (const key of parsed.technicalPoints) {
    try {
      switch (key) {
        case "north_node": {
          const nodeBody: SwissTechnicalBody =
            parsed.nodeType === "mean" ? "MeanNode" : "TrueNode";
          points.push(
            buildSwissPlacement(
              "Nodo Norte",
              nodeBody,
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        }
        case "south_node": {
          const nodeBody: SwissTechnicalBody =
            parsed.nodeType === "mean" ? "MeanNode" : "TrueNode";
          const northNode = buildSwissPlacement(
            "Nodo Norte",
            nodeBody,
            resolvedJulianDay,
            houseContext,
            swiss.swe,
            swiss.calculationFlags,
          );
          points.push(
            buildDerivedPlacement({
              key,
              label: "Nodo Sur",
              longitude: northNode.longitude + 180,
              latitude: 0,
              houseContext,
              retrograde: true,
            }),
          );
          computedKeys.push(key);
          break;
        }
        case "chiron":
          points.push(
            buildSwissPlacement(
              "Quiron",
              "Chiron",
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "lilith":
          points.push(
            buildSwissPlacement(
              "Lilith",
              parsed.lilithType === "true" ? "TrueLilith" : "MeanLilith",
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "fortune": {
          const fortuneLongitude = calculatePartOfFortune({
            ascendantLongitude: ascendant.longitude,
            sunLongitude: sun.longitude,
            moonLongitude: moon.longitude,
            isDayChart: isDayChart(sun),
            mode: parsed.arabicPartsMode,
          });
          points.push(
            buildDerivedPlacement({
              key,
              label: "Parte Fortuna",
              longitude: fortuneLongitude,
              latitude: 0,
              houseContext,
              retrograde: false,
            }),
          );
          computedKeys.push(key);
          break;
        }
        case "misfortune": {
          if (!mars || !saturn) {
            unsupportedKeys.push(key);
            break;
          }
          const misfortuneLongitude = calculatePartOfMisfortune({
            ascendantLongitude: ascendant.longitude,
            marsLongitude: mars.longitude,
            saturnLongitude: saturn.longitude,
            isDayChart: isDayChart(sun),
            mode: parsed.arabicPartsMode,
          });
          points.push(
            buildDerivedPlacement({
              key,
              label: "Parte Infortunio",
              longitude: misfortuneLongitude,
              latitude: 0,
              houseContext,
              retrograde: false,
            }),
          );
          computedKeys.push(key);
          break;
        }
        case "vertex":
          if (vertexLongitude !== undefined) {
            points.push(
              buildDerivedPlacement({
                key,
                label: "Vertex",
                longitude: vertexLongitude,
                latitude: 0,
                houseContext,
                retrograde: false,
              }),
            );
            computedKeys.push(key);
          }
          break;
        case "ceres":
          points.push(
            buildSwissPlacement(
              "Ceres",
              "Ceres",
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "pallas":
          points.push(
            buildSwissPlacement(
              "Palas",
              "Pallas",
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "juno":
          points.push(
            buildSwissPlacement(
              "Juno",
              "Juno",
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "vesta":
          points.push(
            buildSwissPlacement(
              "Vesta",
              "Vesta",
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "pholus":
          points.push(
            buildSwissPlacement(
              "Pholus",
              "Pholus",
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "chariklo":
          points.push(
            buildSwissAsteroidPlacement(
              "Chariklo",
              10199,
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "eros":
          points.push(
            buildSwissAsteroidPlacement(
              "Eros",
              433,
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "eris":
          points.push(
            buildSwissAsteroidPlacement(
              "Eris",
              136199,
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "icarus":
          points.push(
            buildSwissAsteroidPlacement(
              "Icaro",
              1566,
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "nessus":
          points.push(
            buildSwissAsteroidPlacement(
              "Nessus",
              7066,
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
        case "psyche":
          points.push(
            buildSwissAsteroidPlacement(
              "Psique",
              16,
              resolvedJulianDay,
              houseContext,
              swiss.swe,
              swiss.calculationFlags,
              key,
            ),
          );
          computedKeys.push(key);
          break;
      }
    } catch {
      unsupportedKeys.push(key);
      continue;
    }
  }

  return {
    points,
    computedKeys,
    unsupportedKeys: unsupportedKeys.filter(
      (item, index, source) => source.indexOf(item) == index,
    ),
  };
}

function buildDerivedPlacement({
  key,
  label,
  longitude,
  latitude,
  houseContext,
  retrograde,
}: {
  key: string;
  label: string;
  longitude: number;
  latitude: number;
  houseContext: HouseCalculationContext;
  retrograde: boolean;
}): AstroPlacement {
  const normalizedLongitude = normalizeDegrees(longitude);
  const sign = getZodiacSign(normalizedLongitude);

  return {
    key,
    label,
    longitude: normalizedLongitude,
    latitude,
    sign: sign.name,
    signIndex: sign.index,
    degreeInSign: roundTo(normalizedLongitude % 30, 4),
    degreeFormatted: formatDegreeInSign(normalizedLongitude, sign.name),
    house: calculateHouseNumber(normalizedLongitude, houseContext),
    retrograde,
  };
}

function calculatePartOfFortune({
  ascendantLongitude,
  sunLongitude,
  moonLongitude,
  isDayChart,
  mode,
}: {
  ascendantLongitude: number;
  sunLongitude: number;
  moonLongitude: number;
  isDayChart: boolean;
  mode: ArabicPartsMode;
}): number {
  const useDayFormula = mode === "same" ? true : isDayChart;
  return useDayFormula
    ? normalizeDegrees(ascendantLongitude + moonLongitude - sunLongitude)
    : normalizeDegrees(ascendantLongitude + sunLongitude - moonLongitude);
}

function calculatePartOfMisfortune({
  ascendantLongitude,
  marsLongitude,
  saturnLongitude,
  isDayChart,
  mode,
}: {
  ascendantLongitude: number;
  marsLongitude: number;
  saturnLongitude: number;
  isDayChart: boolean;
  mode: ArabicPartsMode;
}): number {
  const useDayFormula = mode === "same" ? true : isDayChart;
  return useDayFormula
    ? normalizeDegrees(ascendantLongitude + marsLongitude - saturnLongitude)
    : normalizeDegrees(ascendantLongitude + saturnLongitude - marsLongitude);
}

function isDayChart(sun: AstroPlacement): boolean {
  return sun.house >= 7 && sun.house <= 12;
}

function filterSelectedPlanets(
  placements: AstroPlacement[],
  selectedPlanets: PlanetKey[],
): AstroPlacement[] {
  const selectedKeys = new Set(selectedPlanets.map(mapPlanetKeyToPlacementKey));
  return placements.filter((placement) => selectedKeys.has(placement.key));
}

function createHouseCalculationContext(
  houseSystem: HouseSystem,
  ascendantLongitude: number,
  ascendantSignIndex: number,
  houseCusps?: number[],
): HouseCalculationContext {
  return {
    houseSystem,
    ascendantLongitude,
    ascendantSignIndex,
    houseCusps,
  };
}

function buildPlacement(
  label: string,
  body: SupportedBody | "Moon",
  date: Date,
  houseContext: HouseCalculationContext,
): AstroPlacement {
  let longitude = 0;
  let latitude = 0;

  if (body === "Moon") {
    const coords = EclipticGeoMoon(date);
    longitude = normalizeDegrees(coords.lon);
    latitude = coords.lat;
  } else {
    const coords = Ecliptic(GeoVector(body, date, true));
    longitude = normalizeDegrees(coords.elon);
    latitude = coords.elat;
  }

  const sign = getZodiacSign(longitude);
  const retrograde =
    body === Body.Sun || body === "Moon"
      ? false
      : isRetrograde(body, date, longitude);

  return {
    key: normalizeKey(label),
    label,
    longitude,
    latitude,
    sign: sign.name,
    signIndex: sign.index,
    degreeInSign: roundTo(longitude % 30, 4),
    degreeFormatted: formatDegreeInSign(longitude, sign.name),
    house: calculateHouseNumber(longitude, houseContext),
    retrograde,
  };
}

function buildAnglePoint(
  key: "ascendant" | "midheaven",
  label: string,
  longitude: number,
  houseContext: HouseCalculationContext,
): AstroAnglePoint {
  const sign = getZodiacSign(longitude);

  return {
    key,
    label,
    longitude,
    sign: sign.name,
    signIndex: sign.index,
    degreeInSign: roundTo(longitude % 30, 4),
    degreeFormatted: formatDegreeInSign(longitude, sign.name),
    house:
      key === "ascendant"
        ? 1
        : calculateHouseNumber(longitude, houseContext),
    ruler: sign.ruler,
  };
}

function buildHouses(houseContext: HouseCalculationContext): AstroHouse[] {
  return Array.from({ length: 12 }, (_, index) => {
    const cuspLongitude = houseContext.houseCusps
      ? normalizeDegrees(houseContext.houseCusps[index] ?? 0)
      : houseContext.houseSystem === "whole_sign"
        ? normalizeDegrees(houseContext.ascendantSignIndex * 30 + index * 30)
        : normalizeDegrees(houseContext.ascendantLongitude + index * 30);
    const signIndex = Math.floor(cuspLongitude / 30) % 12;
    const sign = zodiacSigns[signIndex];

    return {
      number: index + 1,
      sign: sign.name,
      signIndex,
      cuspLongitude,
      cuspDegreeFormatted: formatDegreeInSign(cuspLongitude, sign.name),
      ruler: sign.ruler,
    };
  });
}

function buildAspects(
  planetsData: AstroPlacement[],
  anglePoints: AstroAnglePoint[] = [],
): AstroAspect[] {
  const aspects: AstroAspect[] = [];
  const points: AspectPoint[] = [
    ...planetsData.map((placement) => ({
      label: placement.label,
      displayLabel: placement.label,
      longitude: placement.longitude,
      category: "planet" as const,
    })),
    ...anglePoints.map((angle) => ({
      label: angle.label,
      displayLabel: angle.label,
      longitude: angle.longitude,
      category: "angle" as const,
    })),
  ];

  for (let leftIndex = 0; leftIndex < points.length; leftIndex += 1) {
    for (let rightIndex = leftIndex + 1; rightIndex < points.length; rightIndex += 1) {
      const left = points[leftIndex];
      const right = points[rightIndex];
      if (left.category === "angle" && right.category === "angle") {
        continue;
      }
      const separation = smallestAngleDifference(
        left.longitude,
        right.longitude,
      );

      for (const definition of aspectDefinitions) {
        const orb = Math.abs(separation - definition.angle);
        const maxOrb = resolveAspectMaxOrb(definition, left, right);
        if (orb <= maxOrb) {
          aspects.push({
            type: definition.type,
            exactAngle: definition.angle,
            orb: roundTo(orb, 2),
            maxOrb,
            precision: classifyAspectPrecision(orb, maxOrb),
            left: left.displayLabel,
            right: right.displayLabel,
          });
          break;
        }
      }
    }
  }

  return aspects.sort((left, right) => left.orb - right.orb);
}

function buildCrossAspects(
  leftPlacements: AstroPlacement[],
  rightPlacements: AstroPlacement[],
): AstroAspect[] {
  const aspects: AstroAspect[] = [];
  const leftPoints = leftPlacements.map((placement) => ({
    label: placement.label,
    displayLabel: `Transito ${placement.label}`,
    longitude: placement.longitude,
    category: "planet" as const,
  }));
  const rightPoints = rightPlacements.map((placement) => ({
    label: placement.label,
    displayLabel: `Natal ${placement.label}`,
    longitude: placement.longitude,
    category: "planet" as const,
  }));

  for (const left of leftPoints) {
    for (const right of rightPoints) {
      const separation = smallestAngleDifference(left.longitude, right.longitude);

      for (const definition of aspectDefinitions) {
        const orb = Math.abs(separation - definition.angle);
        const maxOrb = resolveAspectMaxOrb(definition, left, right);
        if (orb <= maxOrb) {
          aspects.push({
            type: definition.type,
            exactAngle: definition.angle,
            orb: roundTo(orb, 2),
            maxOrb,
            precision: classifyAspectPrecision(orb, maxOrb),
            left: left.displayLabel,
            right: right.displayLabel,
          });
          break;
        }
      }
    }
  }

  return aspects.sort((left, right) => left.orb - right.orb);
}

function buildSynastryAspects(
  leftPlacements: AstroPlacement[],
  rightPlacements: AstroPlacement[],
): AstroAspect[] {
  const aspects: AstroAspect[] = [];
  const leftPoints = leftPlacements.map((placement) => ({
    label: placement.label,
    displayLabel: `Carta A ${placement.label}`,
    longitude: placement.longitude,
    category: "planet" as const,
  }));
  const rightPoints = rightPlacements.map((placement) => ({
    label: placement.label,
    displayLabel: `Carta B ${placement.label}`,
    longitude: placement.longitude,
    category: "planet" as const,
  }));

  for (const left of leftPoints) {
    for (const right of rightPoints) {
      const separation = smallestAngleDifference(left.longitude, right.longitude);

      for (const definition of aspectDefinitions) {
        const orb = Math.abs(separation - definition.angle);
        const maxOrb = resolveAspectMaxOrb(definition, left, right);
        if (orb <= maxOrb) {
          aspects.push({
            type: definition.type,
            exactAngle: definition.angle,
            orb: roundTo(orb, 2),
            maxOrb,
            precision: classifyAspectPrecision(orb, maxOrb),
            left: left.displayLabel,
            right: right.displayLabel,
          });
          break;
        }
      }
    }
  }

  return aspects.sort((left, right) => left.orb - right.orb);
}

function buildTransitHighlights(aspects: AstroAspect[]): string[] {
  return aspects.slice(0, 5).map((aspect) => {
    return `${aspect.left} hace ${aspect.type} con ${aspect.right} (orb ${aspect.orb}° de ${aspect.maxOrb}°).`;
  });
}

async function buildActiveTransitWindow({
  aspectsToNatal,
  natalPlacements,
  targetDate,
  houseSystem,
  houseContext,
}: {
  aspectsToNatal: AstroAspect[];
  natalPlacements: AstroPlacement[];
  targetDate: Date;
  houseSystem: HouseSystem;
  houseContext: HouseCalculationContext;
}): Promise<AstroTransitWindow | undefined> {
  const primaryAspect = aspectsToNatal[0];
  if (!primaryAspect) {
    return undefined;
  }

  const context = resolveActiveTransitContext(primaryAspect, natalPlacements);
  if (!context) {
    return undefined;
  }

  const swiss = houseSystem === "placidus" ? await getSwissEphemeris() : null;
  const evaluateAtDate = (date: Date) =>
    evaluateTransitAspectState({
      context,
      date,
      houseSystem,
      houseContext,
      swiss,
    });

  const currentState = await evaluateAtDate(targetDate);
  if (!currentState.active) {
    return undefined;
  }

  const searchConfig = resolveTransitWindowSearchConfig(
    context.transitPlanet.label,
  );
  const startsAt = await searchTransitBoundary({
    origin: targetDate,
    direction: "backward",
    stepMs: searchConfig.stepMs,
    horizonMs: searchConfig.horizonMs,
    evaluateAtDate,
  });
  const endsAt = await searchTransitBoundary({
    origin: targetDate,
    direction: "forward",
    stepMs: searchConfig.stepMs,
    horizonMs: searchConfig.horizonMs,
    evaluateAtDate,
  });

  return {
    transitLabel: context.transitPlanet.label,
    natalLabel: context.natalPlacement.label,
    type: context.aspect.type,
    startsAt: startsAt.toISOString(),
    endsAt: endsAt.toISOString(),
  };
}

function resolveActiveTransitContext(
  aspect: AstroAspect,
  natalPlacements: AstroPlacement[],
):
  | {
      aspect: AstroAspect;
      transitPlanet: PlanetDefinition;
      natalPlacement: AstroPlacement;
    }
  | undefined {
  const transitLabel = aspect.left.replace(/^Transito\s+/i, "").trim();
  const natalLabel = aspect.right.replace(/^Natal\s+/i, "").trim();
  const transitPlanet = planets.find((item) => item.label === transitLabel);
  const natalPlacement = natalPlacements.find((item) => item.label === natalLabel);

  if (!transitPlanet || !natalPlacement) {
    return undefined;
  }

  return {
    aspect,
    transitPlanet,
    natalPlacement,
  };
}

function resolveTransitWindowSearchConfig(label: string): {
  stepMs: number;
  horizonMs: number;
} {
  const hour = 60 * 60 * 1000;
  const day = 24 * hour;

  switch (label) {
    case "Luna":
      return { stepMs: 2 * hour, horizonMs: 4 * day };
    case "Sol":
      return { stepMs: 6 * hour, horizonMs: 21 * day };
    case "Mercurio":
    case "Venus":
      return { stepMs: 12 * hour, horizonMs: 90 * day };
    case "Marte":
      return { stepMs: 12 * hour, horizonMs: 140 * day };
    case "Jupiter":
    case "Saturno":
      return { stepMs: day, horizonMs: 420 * day };
    case "Urano":
    case "Neptuno":
    case "Pluton":
      return { stepMs: 2 * day, horizonMs: 720 * day };
    default:
      return { stepMs: 12 * hour, horizonMs: 120 * day };
  }
}

async function searchTransitBoundary({
  origin,
  direction,
  stepMs,
  horizonMs,
  evaluateAtDate,
}: {
  origin: Date;
  direction: "backward" | "forward";
  stepMs: number;
  horizonMs: number;
  evaluateAtDate: (date: Date) => Promise<{ active: boolean; orb: number }>;
}): Promise<Date> {
  let activePoint = new Date(origin);
  let probeTime = origin.getTime();
  const minTime = origin.getTime() - horizonMs;
  const maxTime = origin.getTime() + horizonMs;

  while (true) {
    const nextProbeTime =
      direction === "backward" ? probeTime - stepMs : probeTime + stepMs;
    if (
      (direction === "backward" && nextProbeTime < minTime) ||
      (direction === "forward" && nextProbeTime > maxTime)
    ) {
      return activePoint;
    }

    const candidate = new Date(nextProbeTime);
    const state = await evaluateAtDate(candidate);

    if (!state.active) {
      return refineTransitBoundary({
        direction,
        activePoint,
        inactivePoint: candidate,
        evaluateAtDate,
      });
    }

    activePoint = candidate;
    probeTime = nextProbeTime;
  }
}

async function refineTransitBoundary({
  direction,
  activePoint,
  inactivePoint,
  evaluateAtDate,
}: {
  direction: "backward" | "forward";
  activePoint: Date;
  inactivePoint: Date;
  evaluateAtDate: (date: Date) => Promise<{ active: boolean; orb: number }>;
}): Promise<Date> {
  let low =
    direction === "backward"
      ? inactivePoint.getTime()
      : activePoint.getTime();
  let high =
    direction === "backward"
      ? activePoint.getTime()
      : inactivePoint.getTime();
  const precisionMs = 60 * 60 * 1000;

  while (high - low > precisionMs) {
    const mid = Math.floor((low + high) / 2);
    const state = await evaluateAtDate(new Date(mid));

    if (state.active) {
      if (direction === "backward") {
        high = mid;
      } else {
        low = mid;
      }
    } else if (direction === "backward") {
      low = mid;
    } else {
      high = mid;
    }
  }

  return new Date(direction === "backward" ? high : low);
}

async function evaluateTransitAspectState({
  context,
  date,
  houseSystem,
  houseContext,
  swiss,
}: {
  context: {
    aspect: AstroAspect;
    transitPlanet: PlanetDefinition;
    natalPlacement: AstroPlacement;
  };
  date: Date;
  houseSystem: HouseSystem;
  houseContext: HouseCalculationContext;
  swiss: Awaited<ReturnType<typeof getSwissEphemeris>> | null;
}): Promise<{
  active: boolean;
  orb: number;
}> {
  const transitPlacement = buildSingleTransitPlacement({
    planet: context.transitPlanet,
    date,
    houseSystem,
    houseContext,
    swiss,
  });
  const separation = smallestAngleDifference(
    transitPlacement.longitude,
    context.natalPlacement.longitude,
  );
  const orb = roundTo(
    Math.abs(separation - context.aspect.exactAngle),
    2,
  );

  return {
    active: orb <= context.aspect.maxOrb,
    orb,
  };
}

function buildSingleTransitPlacement({
  planet,
  date,
  houseSystem,
  houseContext,
  swiss,
}: {
  planet: PlanetDefinition;
  date: Date;
  houseSystem: HouseSystem;
  houseContext: HouseCalculationContext;
  swiss: Awaited<ReturnType<typeof getSwissEphemeris>> | null;
}): AstroPlacement {
  if (houseSystem === "placidus") {
    if (!swiss) {
      throw new Error("No hay efemérides disponibles para calcular tránsitos.");
    }

    return buildSwissPlacement(
      planet.label,
      planet.body,
      toJulianDayUtc(date, swiss.swe),
      houseContext,
      swiss.swe,
      swiss.calculationFlags,
    );
  }

  return buildPlacement(planet.label, planet.body, date, houseContext);
}

function buildSummary(
  planetsData: AstroPlacement[],
  ascendant: AstroAnglePoint,
) {
  const counters = {
    Fuego: 0,
    Tierra: 0,
    Aire: 0,
    Agua: 0,
    Cardinal: 0,
    Fijo: 0,
    Mutable: 0,
  };

  const weightedPlacements = [
    planetsData.find((item) => item.key === "sol"),
    planetsData.find((item) => item.key === "luna"),
    planetsData.find((item) => item.key === "mercurio"),
    planetsData.find((item) => item.key === "venus"),
    planetsData.find((item) => item.key === "marte"),
    {
      sign: ascendant.sign,
    },
  ].filter(Boolean) as Array<{ sign: string }>;

  for (const placement of weightedPlacements) {
    const sign = zodiacSigns.find((item) => item.name === placement.sign);
    if (!sign) {
      continue;
    }

    counters[sign.element] += 1;
    counters[sign.quality] += 1;
  }

  const dominantElement = findDominantCounter(
    [counters.Fuego, counters.Tierra, counters.Aire, counters.Agua],
    ["Fuego", "Tierra", "Aire", "Agua"],
  );
  const dominantQuality = findDominantCounter(
    [counters.Cardinal, counters.Fijo, counters.Mutable],
    ["Cardinal", "Fijo", "Mutable"],
  );
  const ascendantSign = zodiacSigns[ascendant.signIndex];
  const sun = planetsData.find((item) => item.key === "sol");
  const moon = planetsData.find((item) => item.key === "luna");

  if (!sun || !moon) {
    throw new Error("No se encontraron Sol y Luna para resumir la carta.");
  }

  return {
    chartRuler: ascendantSign.ruler,
    dominantElement,
    dominantQuality,
    solarSign: sun.sign,
    lunarSign: moon.sign,
    ascendantSign: ascendant.sign,
  };
}

function buildInterpretation(input: {
  sun: AstroPlacement;
  moon: AstroPlacement;
  ascendant: AstroAnglePoint;
  summary: NatalChartResult["summary"];
}): string[] {
  const sunSign = zodiacSigns[input.sun.signIndex];
  const moonSign = zodiacSigns[input.moon.signIndex];
  const ascendantSign = zodiacSigns[input.ascendant.signIndex];

  return [
    `Tu eje principal combina Sol en ${sunSign.name}, Luna en ${moonSign.name} y Ascendente en ${ascendantSign.name}. Esto mezcla ${sunSign.keyword}, ${moonSign.keyword} y una manera de presentarte ligada a ${ascendantSign.keyword}.`,
    `Predomina el elemento ${input.summary.dominantElement} y la cualidad ${input.summary.dominantQuality}. En una primera lectura, esto sugiere que procesas la vida desde ${describeElement(input.summary.dominantElement)} y te mueves con un ritmo ${describeQuality(input.summary.dominantQuality)}.`,
    `El regente de tu carta es ${input.summary.chartRuler}, porque tu Ascendente cae en ${ascendantSign.name}. Ese planeta merece especial atención cuando avancemos a tránsitos, eclipses y ciclos personales.`,
  ];
}

function buildMoonPhaseEvents(fromDate: Date): AstroEventItem[] {
  const results: AstroEventItem[] = [];
  let quarter = SearchMoonQuarter(fromDate);

  for (let index = 0; index < 4; index += 1) {
    results.push({
      type: "moon_phase",
      label: moonQuarterLabel(quarter.quarter),
      kind: moonQuarterKind(quarter.quarter),
      startsAt: quarter.time.date.toISOString(),
    });
    quarter = NextMoonQuarter(quarter);
  }

  return results;
}

async function buildEclipseEvents(
  fromDate: Date,
  latitude?: number,
  longitude?: number,
): Promise<AstroEventItem[]> {
  try {
    return await getUpcomingNasaEclipses(fromDate);
  } catch {
    return buildCalculatedEclipseEvents(fromDate, latitude, longitude);
  }
}

function buildCalculatedEclipseEvents(
  fromDate: Date,
  latitude?: number,
  longitude?: number,
): AstroEventItem[] {
  const events: AstroEventItem[] = [];
  let solar = SearchGlobalSolarEclipse(fromDate);
  let lunar = SearchLunarEclipse(fromDate);

  for (let index = 0; index < 2; index += 1) {
    const solarLatitude = solar.latitude ?? 0;
    const solarLongitude = solar.longitude ?? 0;
    events.push({
      type: "solar_eclipse_global",
      label: `Eclipse solar ${solar.kind}`,
      kind: solar.kind,
      startsAt: solar.peak.date.toISOString(),
      visibility: `Maximo global cerca de lat ${roundTo(
        solarLatitude,
        3,
      )}, lon ${roundTo(solarLongitude, 3)}`,
      coordinates: {
        latitude: roundTo(solarLatitude, 6),
        longitude: roundTo(solarLongitude, 6),
      },
    });
    solar = NextGlobalSolarEclipse(solar.peak);
  }

  for (let index = 0; index < 2; index += 1) {
    events.push({
      type: "lunar_eclipse",
      label: `Eclipse lunar ${lunar.kind}`,
      kind: lunar.kind,
      startsAt: lunar.peak.date.toISOString(),
      visibility: `Obscuracion ${roundTo(lunar.obscuration * 100, 2)}%`,
    });
    lunar = NextLunarEclipse(lunar.peak);
  }

  void latitude;
  void longitude;

  return events.sort((left, right) => left.startsAt.localeCompare(right.startsAt));
}

async function searchNextLongitudeReturn(
  body: SupportedBody | "Moon",
  targetLongitude: number,
  startDate: Date,
): Promise<AstronomyEngine.AstroTime | null> {
  const stepHours =
    body === Body.Sun ? 12 : body === "Moon" ? 3 : 6;
  const maxDays = body === Body.Sun ? 400 : 40;
  const stepMilliseconds = stepHours * 60 * 60 * 1000;
  const maxSteps = Math.ceil((maxDays * 24 * 60 * 60 * 1000) / stepMilliseconds);
  let previousTime = startDate;
  let previousDelta = await longitudeDeltaForReturn(
    body,
    targetLongitude,
    previousTime,
  );

  for (let step = 1; step <= maxSteps; step += 1) {
    const currentTime = new Date(
      new Date(startDate.getTime() + step * stepMilliseconds),
    );
    const currentDelta = await longitudeDeltaForReturn(
      body,
      targetLongitude,
      currentTime,
    );

    if (
      Math.abs(previousDelta) < 0.000001 ||
      Math.abs(currentDelta) < 0.000001 ||
      Math.sign(previousDelta) !== Math.sign(currentDelta)
    ) {
      const result = await refineLongitudeReturn(
        body,
        targetLongitude,
        previousTime,
        currentTime,
      );

      if (result) {
        return result;
      }
    }

    previousTime = currentTime;
    previousDelta = currentDelta;
  }

  return null;
}

async function longitudeDeltaForReturn(
  body: SupportedBody | "Moon",
  targetLongitude: number,
  date: Date,
): Promise<number> {
  const longitude = await getBodyLongitudeForReturns(body, date);
  return normalizeSignedDegrees(longitude - targetLongitude);
}

async function refineLongitudeReturn(
  body: SupportedBody | "Moon",
  targetLongitude: number,
  leftDate: Date,
  rightDate: Date,
): Promise<AstronomyEngine.AstroTime | null> {
  let left = leftDate;
  let right = rightDate;
  let leftDelta = await longitudeDeltaForReturn(body, targetLongitude, left);
  let rightDelta = await longitudeDeltaForReturn(body, targetLongitude, right);

  if (Math.abs(leftDelta) < 0.000001) {
    return new AstroTime(left);
  }

  if (Math.abs(rightDelta) < 0.000001) {
    return new AstroTime(right);
  }

  if (Math.sign(leftDelta) === Math.sign(rightDelta)) {
    return null;
  }

  for (let iteration = 0; iteration < 50; iteration += 1) {
    const middle = new Date((left.getTime() + right.getTime()) / 2);
    const middleDelta = await longitudeDeltaForReturn(
      body,
      targetLongitude,
      middle,
    );

    if (
      Math.abs(middleDelta) < 0.0000005 ||
      right.getTime() - left.getTime() < 1000
    ) {
      return new AstroTime(middle);
    }

    if (Math.sign(leftDelta) !== Math.sign(middleDelta)) {
      right = middle;
      rightDelta = middleDelta;
    } else {
      left = middle;
      leftDelta = middleDelta;
    }
  }

  return new AstroTime(new Date((left.getTime() + right.getTime()) / 2));
}

function calculateAscendantLongitude(
  date: Date,
  latitude: number,
  longitude: number,
): number {
  const localSiderealRadians = localSiderealTimeRadians(date, longitude);
  const eclipticObliquity = degreesToRadians(
    e_tilt(new AstroTime(date)).tobl,
  );
  const x =
    Math.sin(localSiderealRadians) * Math.cos(eclipticObliquity) +
    Math.tan(degreesToRadians(latitude)) * Math.sin(eclipticObliquity);
  const y = -1 * Math.cos(localSiderealRadians);
  const celestialLongitudeRadians = Math.atan(y / x);
  let ascendantDegrees = radiansToDegrees(celestialLongitudeRadians);

  if (x < 0) {
    ascendantDegrees += 180;
  } else {
    ascendantDegrees += 360;
  }

  if (ascendantDegrees < 180) {
    ascendantDegrees += 180;
  } else {
    ascendantDegrees -= 180;
  }

  return normalizeDegrees(ascendantDegrees);
}

function calculateMidheavenLongitude(date: Date, longitude: number): number {
  const localSiderealRadians = localSiderealTimeRadians(date, longitude);
  const eclipticObliquity = degreesToRadians(
    e_tilt(new AstroTime(date)).tobl,
  );
  const numerator = Math.tan(localSiderealRadians);
  const denominator = Math.cos(eclipticObliquity);
  let midheavenDegrees = radiansToDegrees(Math.atan(numerator / denominator));

  if (midheavenDegrees < 0) {
    midheavenDegrees += 360;
  }

  const localSiderealDegrees = radiansToDegrees(localSiderealRadians);
  if (midheavenDegrees > localSiderealDegrees) {
    midheavenDegrees -= 180;
  }
  if (midheavenDegrees < 0) {
    midheavenDegrees += 180;
  }
  if (midheavenDegrees < 180 && localSiderealDegrees >= 180) {
    midheavenDegrees += 180;
  }

  return normalizeDegrees(midheavenDegrees);
}

function calculateHouseNumber(
  longitude: number,
  houseContext: HouseCalculationContext,
): number {
  if (houseContext.houseCusps && houseContext.houseCusps.length === 12) {
    return calculateHouseFromCusps(longitude, houseContext.houseCusps);
  }

  if (houseContext.houseSystem === "whole_sign") {
    const signIndex = getZodiacSign(longitude).index;
    return ((signIndex - houseContext.ascendantSignIndex + 12) % 12) + 1;
  }

  return (
    Math.floor(
      normalizeDegrees(longitude - houseContext.ascendantLongitude) / 30,
    ) + 1
  );
}

function calculateHouseFromCusps(longitude: number, cusps: number[]): number {
  const normalizedLongitude = normalizeDegrees(longitude);

  for (let index = 0; index < cusps.length; index += 1) {
    const cusp = normalizeDegrees(cusps[index]);
    const nextCusp = normalizeDegrees(cusps[(index + 1) % cusps.length]);
    const span = normalizeDegrees(nextCusp - cusp);
    const offset = normalizeDegrees(normalizedLongitude - cusp);

    if (offset < span || (span === 0 && offset === 0)) {
      return index + 1;
    }
  }

  return 12;
}

function toJulianDayUtc(
  date: Date,
  swe: Awaited<ReturnType<typeof getSwissEphemeris>>["swe"],
): number {
  const hour =
    date.getUTCHours() +
    date.getUTCMinutes() / 60 +
    date.getUTCSeconds() / 3600 +
    date.getUTCMilliseconds() / 3600000;

  return swe.swe_julday(
    date.getUTCFullYear(),
    date.getUTCMonth() + 1,
    date.getUTCDate(),
    hour,
    swe.SE_GREG_CAL,
  );
}

function mapSwissBody(
  body: SupportedBody | "Moon" | SwissTechnicalBody,
  swe: Awaited<ReturnType<typeof getSwissEphemeris>>["swe"],
): number {
  if (body === "Moon") {
    return swe.SE_MOON;
  }

  if (body === "TrueNode") {
    return swe.SE_TRUE_NODE;
  }

  if (body === "MeanNode") {
    return swe.SE_MEAN_NODE;
  }

  if (body === "Chiron") {
    return swe.SE_CHIRON;
  }

  if (body === "MeanLilith") {
    return swe.SE_MEAN_APOG;
  }

  if (body === "TrueLilith") {
    return swe.SE_OSCU_APOG;
  }

  if (body === "Ceres") {
    return swe.SE_CERES;
  }

  if (body === "Pallas") {
    return swe.SE_PALLAS;
  }

  if (body === "Juno") {
    return swe.SE_JUNO;
  }

  if (body === "Vesta") {
    return swe.SE_VESTA;
  }

  if (body === "Pholus") {
    return swe.SE_PHOLUS;
  }

  switch (body) {
    case Body.Sun:
      return swe.SE_SUN;
    case Body.Mercury:
      return swe.SE_MERCURY;
    case Body.Venus:
      return swe.SE_VENUS;
    case Body.Mars:
      return swe.SE_MARS;
    case Body.Jupiter:
      return swe.SE_JUPITER;
    case Body.Saturn:
      return swe.SE_SATURN;
    case Body.Uranus:
      return swe.SE_URANUS;
    case Body.Neptune:
      return swe.SE_NEPTUNE;
    case Body.Pluto:
      return swe.SE_PLUTO;
  }

  throw new Error(`Cuerpo no soportado para Swiss Ephemeris: ${String(body)}.`);
}

function mapPlanetKeyToPlacementKey(key: PlanetKey): string {
  switch (key) {
    case "sun":
      return "sol";
    case "moon":
      return "luna";
    case "mercury":
      return "mercurio";
    case "venus":
      return "venus";
    case "mars":
      return "marte";
    case "jupiter":
      return "jupiter";
    case "saturn":
      return "saturno";
    case "uranus":
      return "urano";
    case "neptune":
      return "neptuno";
    case "pluto":
      return "pluton";
  }
}

async function getBodyLongitudeForReturns(
  body: SupportedBody | "Moon",
  date: Date,
): Promise<number> {
  const swiss = await getSwissEphemeris();
  const julianDayUtc = toJulianDayUtc(date, swiss.swe);
  const coordinates = swiss.swe.swe_calc_ut(
    julianDayUtc,
    mapSwissBody(body, swiss.swe),
    swiss.calculationFlags,
  );

  return normalizeDegrees(coordinates[0]);
}

function localSiderealTimeRadians(date: Date, longitude: number): number {
  const greenwichSiderealTime = SiderealTime(date);
  const localSiderealTime = greenwichSiderealTime + longitude / 15;
  const localSiderealDegrees = normalizeDegrees(localSiderealTime * 15);
  return degreesToRadians(localSiderealDegrees);
}

function isRetrograde(body: SupportedBody, date: Date, currentLongitude: number) {
  const nextDate = new Date(date.getTime() + 24 * 60 * 60 * 1000);
  const nextLongitude = normalizeDegrees(
    Ecliptic(GeoVector(body, nextDate, true)).elon,
  );
  const delta = normalizeSignedDegrees(nextLongitude - currentLongitude);
  return delta < 0;
}

function getMoonLongitude(date: Date): number {
  return normalizeDegrees(EclipticGeoMoon(date).lon);
}

function getZodiacSign(longitude: number): ZodiacSignDefinition {
  const normalized = normalizeDegrees(longitude);
  return zodiacSigns[Math.floor(normalized / 30) % 12];
}

function normalizeDegrees(value: number): number {
  return ((value % 360) + 360) % 360;
}

function normalizeSignedDegrees(value: number): number {
  const normalized = normalizeDegrees(value);
  return normalized > 180 ? normalized - 360 : normalized;
}

function smallestAngleDifference(left: number, right: number): number {
  const separation = Math.abs(normalizeSignedDegrees(left - right));
  return separation > 180 ? 360 - separation : separation;
}

function resolveAspectMaxOrb(
  definition: AspectDefinition,
  left: AspectPoint,
  right: AspectPoint,
): number {
  let maxOrb = definition.baseOrb;
  const luminaryCount = [left.label, right.label].filter(isLuminaryLabel).length;
  const angleCount = [left.label, right.label].filter(isAngleLabel).length;
  const outerCount = [left.label, right.label].filter(isOuterPlanetLabel).length;

  if (luminaryCount === 2) {
    maxOrb += 2;
  } else if (luminaryCount === 1) {
    maxOrb += 1;
  }

  if (angleCount > 0) {
    maxOrb += 1;
  }

  if (outerCount === 2) {
    maxOrb -= 1.5;
  } else if (outerCount === 1 && luminaryCount === 0 && angleCount === 0) {
    maxOrb -= 0.5;
  }

  return roundTo(Math.max(maxOrb, 2.5), 1);
}

function classifyAspectPrecision(
  orb: number,
  maxOrb: number,
): AstroAspect["precision"] {
  if (orb <= 1.5 || orb <= maxOrb * 0.22) {
    return "cerrado";
  }

  if (orb <= maxOrb * 0.55) {
    return "moderado";
  }

  return "amplio";
}

function isLuminaryLabel(label: string): boolean {
  return label === "Sol" || label === "Luna";
}

function isAngleLabel(label: string): boolean {
  return label === "Ascendente" || label === "Medio Cielo";
}

function isOuterPlanetLabel(label: string): boolean {
  return label === "Urano" || label === "Neptuno" || label === "Pluton";
}

function formatDegreeInSign(longitude: number, signName: string): string {
  const normalized = normalizeDegrees(longitude);
  const totalMinutes = Math.round((normalized % 30) * 60);
  const degrees = Math.floor(totalMinutes / 60) % 30;
  const minutes = totalMinutes % 60;
  const roundedLongitude = normalizeDegrees(
    Math.floor(normalized / 30) * 30 + (totalMinutes / 60),
  );
  const roundedSignName = getZodiacSign(roundedLongitude).name;

  return `${degrees.toString().padStart(2, "0")}°${minutes
    .toString()
    .padStart(2, "0")} ${roundedSignName || signName}`;
}

function normalizeKey(value: string): string {
  return value
    .toLowerCase()
    .normalize("NFD")
    .replaceAll(/[\u0300-\u036f]/g, "")
    .replaceAll(/\s+/g, "_");
}

function roundTo(value: number, decimals: number): number {
  const factor = 10 ** decimals;
  return Math.round(value * factor) / factor;
}

function degreesToRadians(value: number): number {
  return (value / 180) * Math.PI;
}

function radiansToDegrees(value: number): number {
  return (value * 180) / Math.PI;
}

function findDominantCounter(values: number[], labels: string[]): string {
  let winnerIndex = 0;

  for (let index = 1; index < values.length; index += 1) {
    if (values[index] > values[winnerIndex]) {
      winnerIndex = index;
    }
  }

  return labels[winnerIndex];
}

function moonQuarterLabel(quarter: number): string {
  switch (quarter) {
    case 0:
      return "Luna nueva";
    case 1:
      return "Cuarto creciente";
    case 2:
      return "Luna llena";
    default:
      return "Cuarto menguante";
  }
}

function moonQuarterKind(quarter: number): string {
  switch (quarter) {
    case 0:
      return "new_moon";
    case 1:
      return "first_quarter";
    case 2:
      return "full_moon";
    default:
      return "last_quarter";
  }
}

function describeElement(element: string): string {
  switch (element) {
    case "Fuego":
      return "acción, deseo y espontaneidad";
    case "Tierra":
      return "realismo, estabilidad y necesidad de concreción";
    case "Aire":
      return "ideas, intercambio y lectura racional de los procesos";
    default:
      return "emoción, intuición y percepción sutil";
  }
}

function describeQuality(quality: string): string {
  switch (quality) {
    case "Cardinal":
      return "de inicio y activación";
    case "Fijo":
      return "de permanencia y consolidacion";
    default:
      return "de cambio, adaptacion y movimiento";
  }
}
