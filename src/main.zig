const std = @import("std");
const SceneBuilder = @import("SceneBuilder.zig");
const Scene = @import("SceneBuilder.zig").Scene;
const Renderer = @import("renderers/MultithreadedRenderer.zig");
const Buffer = @import("Buffer.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    var scene_builder = try SceneBuilder.initTestScene(allocator, .{});
    defer scene_builder.deinit();
    const scene = try scene_builder.build();

    const renderer: Renderer = .{};
    var buffer = try Buffer.init(allocator, scene.cam.image_width, scene.cam._image_height);
    defer buffer.deinit();
    try renderer.render(allocator, &buffer, scene);
    try buffer.writeAsPPM(io, "output.ppm");
}
