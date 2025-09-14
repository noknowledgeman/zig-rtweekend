const std = @import("std");

const MultithreadedRenderer = @This();
const Camera = @import("Camera.zig");
const Buffer = @import("Buffer.zig");
const Hittable = @import("hittable.zig").Hittable;

camera: Camera,

fn renderRow(self: MultithreadedRenderer, buffer: *Buffer, world: Hittable,  j: usize) !void {
    for (0..@as(usize, self.camera.image_width)) |i| {
        const pixel_color = self.camera.render_pixel(world, i, j);

        // ugly getting of internal variables
        try buffer.insertColor(pixel_color.scale(self.camera._pixel_samples_scale), i, j);
    }
}

fn renderMultiThreadBlock(self: MultithreadedRenderer, buffer: *Buffer, world: Hittable, row: usize, len: usize, thread: usize) !void {
    const stderr = std.io.getStdErr().writer();
    for (row..(row + len)) |j| {
        try stderr.print("Thread {} is rendering row {}\n", .{thread, j});
        try self.renderRow(buffer, world, j);
    }
    try stderr.print("Thread {} finished Rendering\n", .{thread});
}

pub fn render(self: MultithreadedRenderer, allocator: std.mem.Allocator, buffer: *Buffer, world: Hittable) !void {
    const num_cores = try std.Thread.getCpuCount();
    const base = self.camera._image_height / num_cores;
    const rem = self.camera._image_height % num_cores;

    var handles = try std.ArrayList(std.Thread).initCapacity(allocator, num_cores);
    defer handles.deinit();

    var offset: usize = 0;
    for (0..num_cores) |core| {
        const len = if (core < rem) base + 1 else base;

        const handle = try std.Thread.spawn(
            .{}, 
            renderMultiThreadBlock, 
            .{self, buffer, world, offset, len, core}
        );
        try handles.append(handle);
        offset += len;
    }

    for (handles.items) |handle| {
        handle.join();
    }
}