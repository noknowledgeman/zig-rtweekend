import index from "./index.html";

const server = Bun.serve({
  routes: {
    "/": index,
    "/wasm": Bun.file("./zig-out/bin/WasmRenderer.wasm"),
  },
  fetch(req) {
    return new Response("Not Found", {status: 404})
  }
})

console.log(`Serving the server on ${server.hostname}:${server.port}`)