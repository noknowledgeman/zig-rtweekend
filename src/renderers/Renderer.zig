const std = @import("std");
const Renderer = @This();
const Camera = @import("Camera.zig");
const Buffer = @import("Buffer.zig");
const Hittable = @import("hittable.zig").Hittable;
const Color = @import("color.zig").Color;

camera: Camera,

pub fn render(self: Renderer, buffer: *Buffer, world: Hittable) !void {
    const stderr = std.io.getStdErr().writer();

    for (0..@as(usize, self.camera._image_height)) |j| {
        try stderr.print("\rScanlines remaining: {} ", .{self.camera._image_height - j});
        for (0..@as(usize, self.camera.image_width)) |i| {
            const pixel_color = self.camera.render_pixel(world, i, j);
    
            // ugly getting of internal variables
            try buffer.insertColor(pixel_color.scale(self.camera._pixel_samples_scale), i, j);
        }
    }

    try stderr.print("\rDone.                           \n", .{});
}

