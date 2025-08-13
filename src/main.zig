const std = @import("std");

const HittableList = @import("HittableList.zig");
const Sphere = @import("Sphere.zig");

const vec3 = @import("vec3.zig");
const Point = vec3.Point;
const Color = @import("color.zig").Color;
const Vec3 = @import("vec3.zig").Vec3;

const Camera = @import("Camera.zig");

const material = @import("material.zig");
const Material = material.Material;

const Interval = @import("Interval.zig");

const util = @import("util.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var world = HittableList.init(allocator);
    defer world.deinit();

    // var material_ground = material.Lambertian{ .albedo = Color.init(0.8, 0.8, 0) };
    // var material_center = material.Lambertian{ .albedo = Color.init(0.1, 0.2, 0.5) };
    // var material_left = material.Dielectric{ .refraction_index = 1.5 };
    // var material_bubble = material.Dielectric{ .refraction_index = (1.0 / 1.5)};
    // var material_right = material.Metallic{ .albedo = Color.init(0.8, 0.6, 0.2), .fuzz = 1.0 };
    //
    // var sphere_ground = Sphere.init(Point.init(0, -100.5, -1.0), 100.0, material_ground.material());
    // var sphere_center = Sphere.init(Point.init(0, 0, -1.2), 0.5, material_center.material());
    // var sphere_left = Sphere.init(Point.init(-1, 0, -1), 0.5, material_left.material());
    // var sphere_bubble = Sphere.init(Point.init(-1, 0, -1), 0.4, material_bubble.material());
    // var sphere_right = Sphere.init(Point.init(1, 0, -1), 0.5, material_right.material());
    //
    // try world.add(sphere_ground.hittable());
    // try world.add(sphere_center.hittable());
    // try world.add(sphere_left.hittable());
    // try world.add(sphere_bubble.hittable());
    // try world.add(sphere_right.hittable());

    // const radius = @cos(std.math.pi/4.0);
    // var material_left = material.Lambertian{ .albedo = Color.init(0, 0, 1) };
    // var material_right = material.Lambertian{ .albedo = Color.init(1, 0, 0) };
    //
    // var sphere_left = Sphere.init(Point.init(-radius, 0, -1.0), radius, material_left.material());
    // var sphere_right = Sphere.init(Point.init(radius, 0, -1.0), radius, material_right.material());
    //
    // try world.add(sphere_right.hittable());
    // try world.add(sphere_left.hittable());

    var cam: Camera = undefined;

    cam.aspect_ratio = 16.0/9.0;
    cam.image_width = 400;
    cam.max_depth = 50;
    cam.samples_per_pixel = 100;

    cam.vfov = 20;
    cam.lookfrom = Point.init(-2.0, 2.0, 1.0);
    cam.lookat = Point.init(0, 0, -1);
    cam.vup = Vec3.init(0, 1, 0);

    cam.defocus_angle = 10.0;
    cam.focus_dist = 3.4;

    cam.init();

    try cam.render(world.hittable());
}
