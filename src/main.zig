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

const BVH = @import("bvh.zig").BVH;

const util = @import("util.zig");

const Renderer = @import("renderers/MultithreadedRenderer.zig");

fn final_render(allocator: std.mem.Allocator) !void {
    
    var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator.deinit();
    const arena = arena_allocator.allocator();

    var world = HittableList.init(arena);
    
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
                    sphere.mat = (try material.Lambertian.init(arena, albedo)).material();
                } else if (choose_mat < 0.95) {
                    const albedo = Color.randomInterval(Interval{.min = 0.5, .max = 1.0});
                    const fuzz = util.randomDoubleInterval(Interval{.min = 0, .max = 0.5});

                    sphere.mat = (try material.Metallic.init(arena, albedo, fuzz)).material();
                } else {
                    sphere.mat = (try material.Dielectric.init(arena, 1.50)).material();
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
        .samples_per_pixel = 5,
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
    
    const renderer = Renderer{.camera = cam};

    var buf = try Buffer.init(arena, cam.image_width, cam._image_height);
    
    const bvh = try BVH.initFromHittables(arena, world.objects.items);
    std.debug.print("Root bbox: ({d},{d}) ({d},{d}) ({d},{d})\n", .{
        bvh.bbox.x.min, bvh.bbox.x.max,
        bvh.bbox.y.min, bvh.bbox.y.max,
        bvh.bbox.z.min, bvh.bbox.z.max,
    });
    
    var list = HittableList.init(arena);
    try list.add(bvh.hittable());
    
    const before = std.time.milliTimestamp();
    try renderer.render(arena, &buf, list.hittable());
    const after = std.time.milliTimestamp();
    
    std.debug.print("The rendering took {d} millis.\n", .{after - before});

    try buf.writeAsPPM("output.ppm");
}

pub fn main() !void {
    var debug_allocator = std.heap.DebugAllocator(.{}).init;
    defer {
        if (debug_allocator.deinit() == .leak) {
            _ = debug_allocator.detectLeaks();
        }
    }
    const allocator = debug_allocator.allocator();
    
    // var sphere1 = Sphere.init(.zero, 1, Material.zero);
    // std.debug.print("sphere 1 at {any} = {any}\n", .{sphere1.center, sphere1.bbox});
    // var sphere2 = Sphere.init(.init(2, 0, 0), 1, Material.zero);
    // std.debug.print("sphere 2 at {any} = {any}\n", .{sphere2.center, sphere2.bbox});
    // var sphere3 = Sphere.init(.init(0, 2, 0), 1, Material.zero);
    // std.debug.print("sphere 3 at {any} = {any}\n", .{sphere3.center, sphere3.bbox});
    // var sphere4 = Sphere.init(.init(0, 0, 2), 1, Material.zero);
    // std.debug.print("sphere 4 at {any} = {any}\n", .{sphere4.center, sphere4.bbox});
    
    // var list: HittableList = .init(allocator);
    // defer list.deinit();
    // try list.add(sphere1.hittable());
    // try list.add(sphere2.hittable());
    // try list.add(sphere3.hittable());
    // try list.add(sphere4.hittable());
    
    // var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    // const arena = arena_allocator.allocator();
    // defer arena_allocator.deinit();
    // const bvh = try BVH.initFromHittables(arena, list.objects.items);
    
    // std.debug.print("{any}\n", .{list.bbox});
    
    // const im_opts: Camera.ImageOptions = .{
    //     .aspect_ratio = (16.0/9.0),
    //     .image_width = 400,
    //     .samples_per_pixel = 5,
    //     .max_depth = 50,
    // };
    // const cam_opts: Camera.CameraOptions = .{
    //     .vfov = 90,
    //     .lookfrom = Point.init(5, 5, 5),
    //     .lookat = Point.init(0, 0, 0),
    //     .vup = Vec3.init(0, 1, 0),
    // };
    // const focus_opts: Camera.FocusOptions = .{
    //     .defocus_angle = 0.6,
    //     .focus_dist = 10.0,
    // };

    // const cam = Camera.init(im_opts, cam_opts, focus_opts);
    
    // const renderer = Renderer{.camera = cam};

    // var buf = try Buffer.init(arena, cam.image_width, cam._image_height);
    
    // const before = std.time.milliTimestamp();
    // try renderer.render(arena, &buf, bvh.hittable());
    // const after = std.time.milliTimestamp();
    
    // std.debug.print("The rendering took {d} millis.\n", .{after - before});

    // try buf.writeAsPPM("output.ppm");
    
    try final_render(allocator);
}
