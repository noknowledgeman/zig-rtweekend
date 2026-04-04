const std = @import("std");

const Interval = @import("Interval.zig");
const Material = @import("material.zig").Material;
const Point = @import("vec3.zig").Point;
const Ray = @import("Ray.zig");
const Vec3 = @import("vec3.zig").Vec3;
const AaBb = @import("AaBb.zig");

pub const HitRecord = struct {
    p: Point,
    normal: Vec3,
    t: f64,
    front_face: bool,
    mat: Material,

    pub fn setFaceNormal(self: *HitRecord, r: Ray,  outward_normal: Vec3) void {
        self.front_face = r.dir.dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.scale(-1.0);
    }
};

pub const Hittable = struct {
    ptr: *anyopaque,
    hitFn: *const fn(ptr: *anyopaque, ray: Ray, ray_t: Interval, hit_record: *HitRecord) bool,
    // TODO: Convert to VTable (idk why)
    boundingBoxFn: ?*const fn(ptr: *anyopaque) AaBb = null,

    pub fn hit(self: Hittable, ray: Ray, ray_t: Interval, hit_record: *HitRecord) bool {
        return self.hitFn(self.ptr, ray, ray_t, hit_record);
    }
    // NOTE: THe bounding box is optional in this case
    pub fn boundingBox(self: Hittable) AaBb {
        if (self.boundingBoxFn) |boundingBoxFn| {
            return boundingBoxFn(self.ptr);
        } else {
            // Bad undefined
            return undefined;
        }
    }
};

