const std = @import("std");

const HittableList = @import("HittableList.zig");
const Sphere = @import("Sphere.zig");

const vec3 = @import("vec3.zig");
const Point = vec3.Point;

const Camera = @import("Camera.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var world = HittableList.init(allocator);
    defer world.deinit();

    var sphere_a = Sphere.init(Point.init(0.0, 0.0, -1.0), 0.5);
    try world.add(sphere_a.hittable());
    var sphere_b = Sphere.init(Point.init(0.0, -100.5, -1.0), 100);
    try world.add(sphere_b.hittable());

    var cam: Camera = undefined;
    
    cam.aspect_ratio = 16.0/9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 10;

    cam.init();
    
    try cam.render(world.hittable());
}
