const std = @import("std");
const SceneBuilder = @import("SceneBuilder.zig");
const Scene = @import("SceneBuilder.zig").Scene;
const Renderer = @import("renderers/MultithreadedRenderer.zig");
const Buffer = @import("Buffer.zig");

pub fn main() !void {
    var debug_allocator = std.heap.DebugAllocator(.{}).init;
    defer {
        if (debug_allocator.deinit() == .leak) {
            _ = debug_allocator.detectLeaks();
        }
    }
    const allocator = debug_allocator.allocator();

    var scene_builder = try SceneBuilder.initTestScene(allocator);
    defer scene_builder.deinit();
    const scene = try scene_builder.build();

    const renderer: Renderer = .{};
    var buffer = try Buffer.init(allocator, scene.cam._image_height, scene.cam.image_width);
    try renderer.render(allocator, &buffer, scene);
}
