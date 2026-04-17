const std = @import("std");
const Hittable = @import("hittable.zig").Hittable;
const HittableList = @import("HittableList.zig");
const Camera = @import("Camera.zig");
const Sphere = @import("primitives/Sphere.zig");
const Material = @import("material.zig").Material;
const Point = @import("vec3.zig").Point;
const Vec3 = @import("vec3.zig").Vec3;
const Interval = @import("Interval.zig");
const BVH = @import("bvh.zig").BVH;
const Color = @import("color.zig").Color;

const util = @import("util.zig");

const SceneBuilder = @This();

cam: Camera,
arena: std.heap.ArenaAllocator,
/// arena allocator
allocator: std.mem.Allocator,
hittable_list: HittableList,
parent_allocator: std.mem.Allocator,

// I want the end scene be some sort of
pub const Scene = struct {
    // prefereably a bvh node if not just any hittable like a HittableList
    root: Hittable,
    cam: Camera,
};

// Heap-allocates SceneBuilder so arena address is stable (avoids dangling allocator.ptr on copy).
pub fn init(child_allocator: std.mem.Allocator, camera: Camera) !*SceneBuilder {
    const self = try child_allocator.create(SceneBuilder);
    self.parent_allocator = child_allocator;
    self.arena = .init(child_allocator);
    self.cam = camera;
    self.allocator = self.arena.allocator();
    self.hittable_list = HittableList.init(self.allocator);
    return self;
}

// its a reference because I dont want to copy but it does mutate
pub fn build(self: *SceneBuilder) !Scene {
    const bvh = try BVH.initFromHittables(self.allocator, self.hittable_list.objects.items);
    
    return .{ 
        .cam = self.cam,
        .root = bvh.hittable(),
    };
}

pub fn addHittable(self: *SceneBuilder, hittable: Hittable) !void {
    return self.hittable_list.add(hittable);
}

pub fn addSphere(self: *SceneBuilder, sphere: Sphere) !void {
    var heap_sphere = try util.createInit(self.allocator, Sphere, sphere);
    try self.hittable_list.add(heap_sphere.hittable());
}

pub fn deinit(self: *SceneBuilder) void {
    const parent = self.parent_allocator;
    self.arena.deinit();
    parent.destroy(self);
}

pub fn initTestScene(allocator: std.mem.Allocator) !*SceneBuilder {
    const im_opts: Camera.ImageOptions = .{
        .aspect_ratio = (16.0/9.0),
        .image_width = 400,
        .samples_per_pixel = 20,
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
    var self = try SceneBuilder.init(allocator, cam);
    
    try self.addSphere(Sphere.init(
        Point.init(0, -1000, 0), 
        1000, 
        .{ .lambertian = Color.init(0.5, 0.5, 0.5) })
    );

    var a: f64 = -11;
    while (a < 11) : (a += 1) {
        var b: f64 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = util.randomDouble();
            const center = Point.init(a+0.9*util.randomDouble(), 0.2, b+0.9*util.randomDouble());
            const radius = 0.2;

            if (center.sub(Point.init(4, 0.2, 0)).length() > 0.9) {
                var sphere = Sphere.init(center, radius, undefined);

                if (choose_mat < 0.8) {
                    const albedo = Color.random().mul(Color.random());
                    sphere.mat = .{ .lambertian = albedo };
                } else if (choose_mat < 0.95) {
                    const albedo = Color.randomInterval(Interval{.min = 0.5, .max = 1.0});
                    const fuzz = util.randomDoubleInterval(Interval{.min = 0, .max = 0.5});

                    sphere.mat = .{ .metallic = .{ .albedo = albedo, .fuzz = fuzz } };
                } else {
                    sphere.mat = .{ .dielectric = 1.5 };
                }
                try self.addSphere(sphere);
            }
        }
    }

    try self.addSphere(Sphere.init(
        Point.init(0, 1, 0), 
        1.0, 
        .{ .dielectric = 1.5 }
    ));

    try self.addSphere(Sphere.init(
        Point.init(-4, 1, 0), 
        1.0, 
        .{ .lambertian = .init(0.4, 0.2, 0.1) }
    ));

    try self.addSphere(Sphere.init(
        Point.init(4, 1, 0), 
        1.0, 
        .{ .metallic = .{ .albedo = .init(0.7, 0.6, 0.5), .fuzz = 0.0 } }
    ));

    return self;
}

