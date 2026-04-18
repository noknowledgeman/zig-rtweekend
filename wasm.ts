/// <reference lib="dom" />

const module = await WebAssembly.instantiateStreaming(fetch("wasm"))

interface WasmExports extends WebAssembly.Exports {
  init: () => void,
  deinit: () => void,
  getBuffer: () => number,
  getWidth: () => number,
  getHeight: () => number,
  renderLine: () => void,
  memory: WebAssembly.Memory,
}

const { init, deinit, getBuffer, getWidth, getHeight, renderLine, memory } = module.instance.exports as WasmExports

init()

const width = getWidth()
const height = getHeight()
let currentLine = 0;

const ptr = getBuffer()

const canvas = document.getElementById("c") as HTMLCanvasElement
canvas.width = width
canvas.height = height
const ctx = canvas.getContext("2d")!
console.log(canvas, ctx)

function renderNextLine() {
  if (currentLine >= height) return
  
  renderLine()
  const pixels = new Uint8ClampedArray(memory.buffer, ptr+currentLine*width*4, width*4)
  const imageData = new ImageData(pixels, width, 1)
  ctx.putImageData(imageData, 0, currentLine)
  
  currentLine++;
  requestAnimationFrame(renderNextLine)
}

requestAnimationFrame(renderNextLine)


deinit()