import { cpSync, existsSync, rmSync } from "node:fs";
import { resolve } from "node:path";

const clientRoot = resolve("dist/client");
const nestedRoot = resolve(clientRoot, "presentation-template");
const nestedAssets = resolve(nestedRoot, "_next");
const publicAssets = resolve(clientRoot, "_next");

if (existsSync(nestedAssets)) {
  cpSync(nestedAssets, publicAssets, { recursive: true });
  rmSync(nestedRoot, { recursive: true, force: true });
  console.log("Prepared GitHub Pages asset tree at dist/client/_next.");
}

if (!existsSync(resolve(clientRoot, "index.html")) || !existsSync(resolve(clientRoot, "layouts.json")) || !existsSync(publicAssets)) {
  throw new Error("Static Pages output is incomplete.");
}
