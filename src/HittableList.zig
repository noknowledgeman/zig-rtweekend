const std = @import("std");

const HitRecord = @import("hittable.zig").HitRecord;
const Hittable = @import("hittable.zig").Hittable;
const Interval = @import("Interval.zig");
const Ray = @import("Ray.zig");
const AaBb = @import("AaBb.zig");

const HittableList = @This();

objects: std.ArrayList(Hittable),
allocator: std.mem.Allocator,
bbox: AaBb = .{},

pub fn init(allocator: std.mem.Allocator) HittableList {
    return .{
        .allocator = allocator,
        .objects = std.ArrayList(Hittable).empty,
    };
}

pub fn deinit(self: *HittableList) void {
    self.objects.deinit(self.allocator);
}

fn hit(ptr: *anyopaque, ray: Ray, ray_t: Interval, hit_record: *HitRecord) bool {
    const self: *HittableList = @ptrCast(@alignCast(ptr));

    var temp_rec: HitRecord = undefined;
    var hit_anything = false;
    var closest_so_far = ray_t.max;


    for (self.objects.items) |object| {
        if (object.hit(ray, Interval{.min=ray_t.min, .max=closest_so_far}, &temp_rec)) {
            hit_anything = true;
            closest_so_far = temp_rec.t;

            hit_record.* = temp_rec;
        }
    }

    return hit_anything;
}

fn boundingBox(ptr: *anyopaque) AaBb {
    const self: *HittableList = @ptrCast(@alignCast(ptr));
    return self.bbox;
}

pub fn hittable(self: *HittableList) Hittable {
    return .{
        .hitFn = hit,
        .boundingBoxFn = boundingBox,
        .ptr = self,
    };
}

pub fn add(self: *HittableList, object: Hittable) !void  {
    try self.objects.append(self.allocator, object);
    // std.debug.print("{d}: {any}\n", .{self.objects.items.len, self.bbox});
    self.bbox = AaBb.combine(self.bbox, object.boundingBox());
}
