import { serve } from "@hono/node-server";
import app from "./app";

const port = 3000;
console.log("Run dev server on port: ", `http://localhost:${port}`);
serve({
  fetch: app.fetch,
  port,
});
