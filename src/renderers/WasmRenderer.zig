const std = @import("std");
const Camera = @import("../Camera.zig");
const Buffer = @import("../Buffer.zig");
const Hittable = @import("../hittable.zig").Hittable;
const Color = @import("../color.zig").Color;

const WASMRenderer = @This();

camera: Camera,
allocator: std.mem.Allocator,

export fn init() void {
    // var self: WasmRenderer = undefined;
    
    std.heap.WasmAllocator{};
}


pub fn renderLine(self: WASMRenderer, allocator: std.mem.Allocator, buffer: *Buffer, world: Hittable) !void {
    _ = allocator;
    

    for (0..@as(usize, self.camera._image_height)) |j| {
        std.debug.print("\rScanlines remaining: {} ", .{self.camera._image_height - j});
        for (0..@as(usize, self.camera.image_width)) |i| {
            const pixel_color = self.camera.render_pixel(world, i, j);
    
            // ugly getting of internal variables
            try buffer.insertColor(pixel_color.scale(self.camera._pixel_samples_scale), i, j);
        }
    }

    std.debug.print("\rDone.                           \n", .{});
}
