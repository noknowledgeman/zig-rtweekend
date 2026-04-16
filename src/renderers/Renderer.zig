const std = @import("std");
const Renderer = @This();
const Camera = @import("../Camera.zig");
const Buffer = @import("../Buffer.zig");
const Hittable = @import("../hittable.zig").Hittable;
const Color = @import("../color.zig").Color;
const Scene = @import("../SceneBuilder.zig").Scene;

// I kind of want the renderers to have this similar structure
pub fn render(self: Renderer, allocator: std.mem.Allocator, buffer: *Buffer, scene: Scene) !void {
    _ = self;
    _ = allocator;

    for (0..@as(usize, scene.cam._image_height)) |j| {
        std.debug.print("\rScanlines remaining: {} ", .{scene.cam._image_height - j});
        for (0..@as(usize, scene.cam.image_width)) |i| {
            const pixel_color = scene.cam.render_pixel(scene.root, i, j);
    
            // ugly getting of internal variables
            try buffer.insertColor(pixel_color.scale(scene.cam._pixel_samples_scale), i, j);
        }
    }

    std.debug.print("\rDone.                           \n", .{});
}

