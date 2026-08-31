import { createReadStream, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, resolve, sep } from "node:path";

const host = "127.0.0.1";
const port = Number(process.env.PORT ?? 4173);
const prefix = "/presentation-template";
const root = resolve("dist/client");
const types = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".png": "image/png",
  ".rsc": "text/x-component",
  ".svg": "image/svg+xml",
};

createServer((request, response) => {
  const url = new URL(request.url ?? "/", `http://${host}:${port}`);
  if (!url.pathname.startsWith(prefix)) {
    response.writeHead(404).end("Not found");
    return;
  }
  const relative = decodeURIComponent(url.pathname.slice(prefix.length)) || "/";
  let path = resolve(root, `.${relative}`);
  if (!(path === root || path.startsWith(`${root}${sep}`))) {
    response.writeHead(403).end("Forbidden");
    return;
  }
  try {
    if (statSync(path).isDirectory()) path = resolve(path, "index.html");
    const stat = statSync(path);
    response.writeHead(200, {
      "Content-Length": stat.size,
      "Content-Type": types[extname(path)] ?? "application/octet-stream",
    });
    createReadStream(path).pipe(response);
  } catch {
    response.writeHead(404).end("Not found");
  }
}).listen(port, host, () => {
  console.log(`Pages preview: http://${host}:${port}${prefix}/`);
});
