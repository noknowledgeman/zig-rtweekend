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

const Buffer = @import("Buffer.zig");

const util = @import("util.zig");

/// Expects an arena allocator 
fn final_render(allocator: std.mem.Allocator, world: *HittableList) !void {
    var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator.deinit();
    const arena = arena_allocator.allocator();

    var ground_material = material.Lambertian{ .albedo = Color.init(0.5, 0.5, 0.5) };
    var ground_sphere = Sphere.init(Point.init(0, -1000, 0), 1000, ground_material.material());
    try world.add(ground_sphere.hittable());

    var a: f64 = -11;
    while (a < 11) : (a += 1) {
        var b: f64 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = util.randomDouble();
            const center = Point.init(a+0.9*util.randomDouble(), 0.2, b+0.9*util.randomDouble());
            const radius = 0.2;

            if (center.sub(Point.init(4, 0.2, 0)).length() > 0.9) {
                var sphere = try arena.create(Sphere);
                sphere.* = Sphere.init(center, radius, undefined);

                if (choose_mat < 0.8) {
                    const albedo = Color.random().mul(Color.random());
                    sphere.mat = (try material.Lambertian.init(allocator, albedo)).material();
                } else if (choose_mat < 0.95) {
                    const albedo = Color.randomInterval(Interval{.min = 0.5, .max = 1.0});
                    const fuzz = util.randomDoubleInterval(Interval{.min = 0, .max = 0.5});

                    sphere.mat = (try material.Metallic.init(allocator, albedo, fuzz)).material();
                } else {
                    sphere.mat = (try material.Dielectric.init(allocator, 1.50)).material();
                }
                try world.add(sphere.hittable());
            }
        }
    }

    var material1 = material.Dielectric{ .refraction_index = 1.5 };
    var sphere1 = Sphere.init(Point.init(0, 1, 0), 1.0, material1.material());
    try world.add(sphere1.hittable());

    var material2 = material.Lambertian{ .albedo = Color.init(0.4, 0.2, 0.1) };
    var sphere2 = Sphere.init(Point.init(-4, 1, 0), 1.0, material2.material());
    try world.add(sphere2.hittable());

    var material3 = material.Metallic{ .albedo = Color.init(0.7, 0.6, 0.5), .fuzz = 0.0 };
    var sphere3 = Sphere.init(Point.init(4, 1, 0), 1.0, material3.material());
    try world.add(sphere3.hittable());

    const im_opts: Camera.ImageOptions = .{
        .aspect_ratio = (16.0/9.0),
        .image_width = 400,
        .samples_per_pixel = 100,
        .max_depth = 50,
    };
    const cam_opts: Camera.CameraOptions = .{
        .vfov = 20,
        .lookfrom = Point.init(13, 2, 3),
        .lookat = Point.init(0, 0, 0),
        .vup = Vec3.init(0, 1, 0),
    };
    const focus_opts: Camera.FocusOptions = .{
        .defocus_angle = 0.6,
        .focus_dist = 10.0,
    };

    const cam = Camera.init(im_opts, cam_opts, focus_opts);

    var buf = try Buffer.init(allocator, cam.image_width, cam._image_height);
    try cam.render(&buf, world.hittable());

    try buf.writeAsPPM("output.ppm");
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var world = HittableList.init(allocator);
    defer world.deinit();


    try final_render(allocator, &world);

    // set up the world
    // var material_ground = material.Lambertian{ .albedo = Color.init(0.8, 0.8, 0.0) };
    // var material_center = material.Lambertian{ .albedo = Color.init(0.1, 0.2, 0.5) };
    // var material_left = material.Dielectric{ .refraction_index = 1.50 };
    // var material_bubble = material.Dielectric{ .refraction_index = (1.00/1.50) };
    // var material_right = material.Metallic{ .albedo = Color.init(0.8, 0.6, 0.2), .fuzz = 1.0 };
    //
    // var sphere_ground = Sphere.init(Point.init(0.0, -100.5, -1.0), 100.0, material_ground.material());
    // var sphere_center = Sphere.init(Point.init(0.0, 0.0, -1.2), 0.5, material_center.material());
    // var sphere_left = Sphere.init(Point.init(-1.0, 0.0, -1.0), 0.5, material_left.material());
    // var sphere_bubble = Sphere.init(Point.init(-1.0, 0.0, -1.0), 0.4, material_bubble.material());
    // var sphere_right = Sphere.init(Point.init(1.0, 0.0, -1.0), 0.5, material_right.material());
    //
    // try world.add(sphere_ground.hittable());
    // try world.add(sphere_center.hittable());
    // try world.add(sphere_left.hittable());
    // try world.add(sphere_bubble.hittable());
    // try world.add(sphere_right.hittable());
    //
    // set up the camera
    // const im_opts: Camera.ImageOptions = .{
    //     .aspect_ratio = (16.0/9.0),
    //     .image_width = 400,
    //     .samples_per_pixel = 100,
    //     .max_depth = 50,
    // };
    // const cam_opts: Camera.CameraOptions = .{
    //     .vfov = 20,
    //     .lookfrom = Point.init(-2, 2, 1),
    //     .lookat = Point.init(0, 0, -1),
    //     .vup = Vec3.init(0, 1, 0),
    // };
    // const focus_opts: Camera.FocusOptions = .{
    //     .defocus_angle = 10.0,
    //     .focus_dist = 3.4,
    // };
    //
    // const cam = Camera.init(im_opts, cam_opts, focus_opts);
    //
    // // set up the Buffer and render to the buffer
    // var buf = try Buffer.init(allocator, cam.image_width, cam._image_height);
    // try cam.render(&buf, world.hittable());
    //
    // try buf.writeAsPPM("output.ppm");
}
