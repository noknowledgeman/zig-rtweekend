const std = @import("std");
const Ray = @import("Ray.zig");
const Vec3 = @import("vec3.zig").Vec3;
const Point = @import("vec3.zig").Point;
const Interval = @import("Interval.zig");

pub const HitRecord = struct {
    p: Point,
    normal: Vec3,
    t: f64,
    front_face: bool,

    pub fn setFaceNormal(self: *HitRecord, r: Ray,  outward_normal: Vec3) void {
        self.front_face = r.dir.dot(outward_normal) < 0;
        if (self.front_face) {
            self.normal = outward_normal;
        } else {
            self.normal = outward_normal.scale(-1);
        }
    }
};

// TODO: fix this interface idk how it works
pub const Hittable = struct {
    ptr: *anyopaque,
    hitFn: *const fn(ptr: *anyopaque, ray: Ray, ray_t: Interval, hit_record: *HitRecord) bool,

    pub fn hit(self: Hittable, ray: Ray, ray_t: Interval, hit_record: *HitRecord) bool {
        return self.hitFn(self.ptr, ray, ray_t, hit_record);
    }
};

