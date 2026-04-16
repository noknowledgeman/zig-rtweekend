const std = @import("std");
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
const Ray = @import("Ray.zig");
const Interval = @import("Interval.zig");

const Triangle = @This();

fn hit(ptr: *anyopaque, ray: Ray, ray_t: Interval, hit_record: *HitRecord) bool {
    const self: *Triangle = @ptrCast(@alignCast(ptr));
    _ = self;
    _ = ray;
    _ = ray_t;
    _ = hit_record;
}

pub fn hittable(self: *Triangle) Hittable {
    return .{
        .ptr = self,
        .hitFn = hit,
    };
}