const HitRecord = @import("hittable.zig").HitRecord;
const Hittable = @import("hittable.zig").Hittable;
const Ray = @import("Ray.zig");
const std = @import("std");
const HittableList = @This();
const Interval = @import("Interval.zig");

objects: std.ArrayList(Hittable),
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) HittableList {
    return .{
        .allocator = allocator,
        .objects = std.ArrayList(Hittable).init(allocator),
    };
}

pub fn deinit(self: *HittableList) void {
    self.objects.deinit();
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

pub fn hittable(self: *HittableList) Hittable {
    return .{
        .hitFn = hit,
        .ptr = self,
    };
}

pub fn add(self: *HittableList, object: Hittable) !void  {
    try self.objects.append(object);
}

