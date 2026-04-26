import { createServer } from "node:http";
import Fastify from "fastify";
import { createBareServer } from "@nebula-services/bare-server-node";
import { server as wisp } from "@mercuryworkshop/wisp-js/server";

const bare = createBareServer("/bare/", { logErrors: true, blockLocal: false });

const app = Fastify({
  logger: true,
  serverFactory: (handler) =>
    createServer()
      .on("request", (req, res) => {
        if (bare.shouldRoute(req)) bare.routeRequest(req, res);
        else handler(req, res);
      })
      .on("upgrade", (req, socket, head) => {
        if (bare.shouldRoute(req)) bare.routeUpgrade(req, socket, head);
        else wisp.routeRequest(req, socket, head);
      }),
});

app.get("/", async () => ({ service: "unstable-backend", status: "ok" }));
app.get("/health", async () => ({ ok: true }));

const host = process.env.HOST || "0.0.0.0";
const port = process.env.PORT ? Number(process.env.PORT) : 3000;
await app.listen({ host, port });
console.log(`unstable-backend listening on http://${host}:${port}`);
