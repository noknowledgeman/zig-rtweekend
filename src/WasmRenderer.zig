const std = @import("std");
const Camera = @import("Camera.zig");
const Buffer = @import("Buffer.zig");
const Hittable = @import("hittable.zig").Hittable;
const Color = @import("color.zig").Color;
const SceneBuilder = @import("SceneBuilder.zig");
const Scene = @import("SceneBuilder.zig").Scene;

const WasmRenderer = @This();

scene_builder: *SceneBuilder,
scene: Scene,
allocator: std.mem.Allocator,
current_line: usize = 0,
buffer: Buffer,

var renderer: ?WasmRenderer = null;

export fn init() void {
    
    const wasm_allocator = std.heap.wasm_allocator;
    
    const builder = SceneBuilder.initTestScene(wasm_allocator) catch unreachable;
    const scene = builder.build() catch unreachable;
    
    renderer = WasmRenderer{
        .allocator = wasm_allocator,
        .scene_builder = builder,
        .scene = scene,
        .buffer = Buffer.init(wasm_allocator, scene.cam.image_width, scene.cam._image_height) catch unreachable,
    };
}

export fn deinit() void {
    renderer.?.scene_builder.deinit();
}

export fn getBuffer() [*]u8 {
    return renderer.?.buffer.buf.ptr;
}

export fn getWidth() u32 {
    return renderer.?.buffer.x;
}

export fn getHeight() u32 {
    return renderer.?.buffer.y;
}

export fn renderLine() bool {
    if (renderer.?.current_line >= renderer.?.scene.cam._image_height) return false;
    for (0..@as(usize, renderer.?.scene.cam.image_width)) |i| {
        const pixel_color = renderer.?.scene.cam.render_pixel(renderer.?.scene.root, i, renderer.?.current_line);

        renderer.?.buffer.insertColor(pixel_color, i, renderer.?.current_line) catch return false;
    }
    renderer.?.current_line += 1;
    return true;
}
