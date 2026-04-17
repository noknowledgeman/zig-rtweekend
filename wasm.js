
console.log("Hello")
const module = await WebAssembly.instantiateStreaming(fetch("WasmRenderer.wasm"))
console.log("Downloaded")

const { init, deinit, getBuffer, getWidth, getHeight, renderLine } = module.instance.exports

init()

const width = getWidth()
const height = getHeight()
let currentLine = 0;

const ptr = getBuffer()

const canvas = document.getElementById("c")
canvas.width = width
canvas.height = height
const ctx = canvas.getContext("2d")
console.log(canvas, ctx)

function renderNextLine() {
  if (currentLine >= height) return
  
  renderLine()
  const pixels = new Uint8ClampedArray(module.instance.exports.memory.buffer, ptr+currentLine*width*4, width*4)
  const imageData = new ImageData(pixels, width, 1)
  ctx.putImageData(imageData, 0, currentLine)
  
  currentLine++;
  requestAnimationFrame(renderNextLine)
}

requestAnimationFrame(renderNextLine)


deinit()