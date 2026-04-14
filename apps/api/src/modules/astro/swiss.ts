import fs from "node:fs/promises";
import path from "node:path";
import { createRequire } from "node:module";
import { pathToFileURL } from "node:url";

import SwissEPH from "sweph-wasm";

export interface SwissEphemerisContext {
  swe: InstanceType<typeof SwissEPH>;
  calculationFlags: number;
  source: "swisseph" | "moshier";
}

type SwissRuntime = ConstructorParameters<typeof SwissEPH>[0];
type SwissWasmFactory = (options: {
  wasmBinary: Uint8Array<ArrayBufferLike>;
}) => Promise<SwissRuntime>;

const requiredEphemerisFiles = ["sepl_18.se1", "semo_18.se1", "seas_18.se1"];

let swissEphemerisPromise: Promise<SwissEphemerisContext> | undefined;

export function getSwissEphemeris(): Promise<SwissEphemerisContext> {
  swissEphemerisPromise ??= initializeSwissEphemeris();
  return swissEphemerisPromise;
}

async function initializeSwissEphemeris(): Promise<SwissEphemerisContext> {
  const require = createRequire(import.meta.url);
  const distDirectory = path.dirname(require.resolve("sweph-wasm"));
  const wasmFactoryPath = path.join(distDirectory, "wasm", "swisseph.js");
  const wasmBinaryPath = path.join(distDirectory, "wasm", "swisseph.wasm");
  const wasmFactoryModule = (await import(
    pathToFileURL(wasmFactoryPath).href
  )) as { default: SwissWasmFactory };
  const wasmBinary = await fs.readFile(wasmBinaryPath);
  const runtime = await wasmFactoryModule.default({ wasmBinary });
  const swe = new SwissEPH(runtime);
  let source: SwissEphemerisContext["source"] = "swisseph";

  try {
    await swe.swe_set_ephe_path(undefined, requiredEphemerisFiles);
  } catch {
    source = "moshier";
  }

  return {
    swe,
    calculationFlags:
      (source === "swisseph" ? swe.SEFLG_SWIEPH : swe.SEFLG_MOSEPH) |
      swe.SEFLG_SPEED,
    source,
  };
}
