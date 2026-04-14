import { readdir, readFile } from "node:fs/promises";
import { dirname, extname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const tarotImagesDirectory = resolve(
  dirname(fileURLToPath(import.meta.url)),
  "../../../../imagenestarot",
);
const supportedExtensions = new Set([".png", ".jpg", ".jpeg", ".webp"]);

const slugAliases = new Map<string, string>([
  ["la-fuerza", "fuerza"],
  ["la-templanza", "templanza"],
  ["la-justicia", "justicia"],
  ["el-juicio", "juicio"],
  ["la-muerte", "muerte"],
  ["la-rueda", "rueda-de-la-fortuna"],
  ["la-rueda-de-la-fortuna", "rueda-de-la-fortuna"],
]);

export interface TarotImageItem {
  slug: string;
  filename: string;
  imageUrl: string;
}

interface TarotImageFile {
  slug: string;
  filename: string;
  filePath: string;
  contentType: string;
}

let tarotCatalogPromise: Promise<Map<string, TarotImageFile>> | null = null;

function slugify(value: string): string {
  return value
    .normalize("NFD")
    .replace(/\p{Diacritic}+/gu, "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "");
}

function resolveContentType(extension: string): string {
  switch (extension) {
    case ".png":
      return "image/png";
    case ".jpg":
    case ".jpeg":
      return "image/jpeg";
    case ".webp":
      return "image/webp";
    default:
      return "application/octet-stream";
  }
}

function buildTarotCardImagePathFromSlug(slug: string): string {
  return `/api/tarot/cards/${slug}/image`;
}

async function loadTarotCatalog(): Promise<Map<string, TarotImageFile>> {
  const entries = await readdir(tarotImagesDirectory, { withFileTypes: true });
  const catalog = new Map<string, TarotImageFile>();

  for (const entry of entries) {
    if (!entry.isFile()) {
      continue;
    }

    const extension = extname(entry.name).toLowerCase();
    if (!supportedExtensions.has(extension)) {
      continue;
    }

    const filename = entry.name;
    const basename = filename.slice(0, -extension.length);
    const slug = slugify(basename);

    if (slug.length === 0 || catalog.has(slug)) {
      continue;
    }

    catalog.set(slug, {
      slug,
      filename,
      filePath: join(tarotImagesDirectory, filename),
      contentType: resolveContentType(extension),
    });
  }

  return catalog;
}

async function getTarotCatalog(): Promise<Map<string, TarotImageFile>> {
  if (!tarotCatalogPromise) {
    tarotCatalogPromise = loadTarotCatalog().catch((error) => {
      tarotCatalogPromise = null;
      throw error;
    });
  }

  return tarotCatalogPromise;
}

export function resolveTarotCardSlug(cardName: string): string {
  const normalized = slugify(cardName);
  if (normalized.length === 0) {
    return "";
  }

  return slugAliases.get(normalized) ?? normalized;
}

export function buildTarotCardImagePath(cardName: string): string | null {
  const slug = resolveTarotCardSlug(cardName);
  return slug.length > 0 ? buildTarotCardImagePathFromSlug(slug) : null;
}

export async function listTarotImageItems(): Promise<TarotImageItem[]> {
  const catalog = await getTarotCatalog();

  return Array.from(catalog.values())
    .sort((left, right) => left.slug.localeCompare(right.slug))
    .map((item) => ({
      slug: item.slug,
      filename: item.filename,
      imageUrl: buildTarotCardImagePathFromSlug(item.slug),
    }));
}

export async function getTarotImageContent(slug: string): Promise<{
  contentType: string;
  filename: string;
  bytes: Uint8Array;
}> {
  const normalizedSlug = resolveTarotCardSlug(slug);
  if (normalizedSlug.length === 0) {
    throw new Error("La carta solicitada no tiene un slug válido.");
  }

  const catalog = await getTarotCatalog();
  const item = catalog.get(normalizedSlug);

  if (!item) {
    throw new Error("No se encontro la imagen solicitada.");
  }

  return {
    contentType: item.contentType,
    filename: item.filename,
    bytes: await readFile(item.filePath),
  };
}
