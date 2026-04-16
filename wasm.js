import fs from 'fs'

new WebAssembly.Module(fs.readFileSync("main.wasm"))