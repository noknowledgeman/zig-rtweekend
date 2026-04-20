const std = @import("std");

const MultithreadedRenderer = @This();
const Camera = @import("../Camera.zig");
const Buffer = @import("../Buffer.zig");
const Hittable = @import("../hittable.zig").Hittable;
const Scene = @import("../SceneBuilder.zig").Scene;


const ThreadSafeIndexes = struct {
    current: std.atomic.Value(usize) = .init(0),
    max: usize,
    
    pub fn pop(self: *ThreadSafeIndexes) ?usize {
        const index = self.current.fetchAdd(1, .monotonic);
        if (index >= self.max) {
            return null;
        }
        return index;
    }
};

fn renderRow(buffer: *Buffer, scene: Scene, row: usize) !void {
    for (0..@as(usize, scene.cam.image_width)) |i| {
        const pixel_color = scene.cam.render_pixel(scene.root, i, row);

        // ugly getting of internal variables
        try buffer.insertColor(pixel_color, i, row);
    }
}

fn renderMultiThreadBlock(buffer: *Buffer, scene: Scene, queue: *ThreadSafeIndexes, thread: usize) !void {
    while (queue.pop()) |row| {
        std.debug.print("Thread {} is rendering row {}\n", .{thread, row});
        try renderRow(buffer, scene, row);
    }
}

pub fn render(self: MultithreadedRenderer, allocator: std.mem.Allocator, buffer: *Buffer, scene: Scene) !void {
    _ = self;
    const num_cores = try std.Thread.getCpuCount();

    var handles = try std.ArrayList(std.Thread).initCapacity(allocator, num_cores);
    defer handles.deinit(allocator);
    
    var queue: ThreadSafeIndexes = .{.max = scene.cam._image_height};

    for (0..num_cores) |core| {
        const handle = try std.Thread.spawn(
            .{}, 
            renderMultiThreadBlock, 
            .{buffer, scene, &queue, core}
        );
        try handles.append(allocator, handle);
    }

    for (handles.items) |handle| {
        handle.join();
    }
}