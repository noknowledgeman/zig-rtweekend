const std = @import("std");

const MultithreadedRenderer = @This();
const Camera = @import("../Camera.zig");
const Buffer = @import("../Buffer.zig");
const Hittable = @import("../hittable.zig").Hittable;


const ThreadSafeQueue = struct {
    current: std.atomic.Value(usize) = .init(0),
    max: usize,
    
    pub fn pop(self: *ThreadSafeQueue) ?usize {
        const index = self.current.fetchAdd(1, .monotonic);
        if (index >= self.max) {
            return null;
        }
        return index;
    }
};

camera: Camera,

fn renderRow(self: MultithreadedRenderer, buffer: *Buffer, world: Hittable,  row: usize) !void {
    for (0..@as(usize, self.camera.image_width)) |i| {
        const pixel_color = self.camera.render_pixel(world, i, row);

        // ugly getting of internal variables
        try buffer.insertColor(pixel_color.scale(self.camera._pixel_samples_scale), i, row);
    }
}

fn renderMultiThreadBlock(self: MultithreadedRenderer, buffer: *Buffer, world: Hittable, queue: *ThreadSafeQueue, thread: usize) !void {
    while (queue.pop()) |row| {
        std.debug.print("Thread {} is rendering row {}\n", .{thread, row});
        try self.renderRow(buffer, world, row);
    }
}

pub fn render(self: MultithreadedRenderer, allocator: std.mem.Allocator, buffer: *Buffer, world: Hittable) !void {
    const num_cores = try std.Thread.getCpuCount();

    var handles = try std.ArrayList(std.Thread).initCapacity(allocator, num_cores);
    defer handles.deinit(allocator);
    
    var queue: ThreadSafeQueue = .{.max = self.camera._image_height};

    for (0..num_cores) |core| {
        const handle = try std.Thread.spawn(
            .{}, 
            renderMultiThreadBlock, 
            .{self, buffer, world, &queue, core}
        );
        try handles.append(allocator, handle);
    }

    for (handles.items) |handle| {
        handle.join();
    }
}