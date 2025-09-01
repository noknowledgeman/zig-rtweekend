const std = @import("std");
const Interval = @import("Interval.zig");
const Vec3 = @import("vec3.zig").Vec3;
const Point = @import("vec3.zig").Point;
const Ray = @import("Ray.zig");

/// The Axis=aligned boundinng box class, can be initialized as  a struct
const AaBb = @This();

x: Interval = .{},
y: Interval = .{},
z: Interval = .{},

pub fn initWithPoints(a: Point, b: Point) AaBb {
    return .{
        .x = if (a.x() <= b.x()) Interval{ .min = a.x(), .max = b.x() } else Interval{ .min = b.x(), .max = a.x() },
        .y = if (a.y() <= b.y()) Interval{ .min = a.y(), .max = b.y() } else Interval{ .min = b.y(), .max = a.y() },
        .z = if (a.z() <= b.z()) Interval{ .min = a.z(), .max = b.z() } else Interval{ .min = b.z(), .max = a.z() },
    };
}

pub fn axisInterval(self: AaBb, n: u32) Interval {
    if (n == 1) return self.y;
    if (n == 2) return self.z;
    return self.x;
} 

pub fn hit(self: AaBb, r: Ray, ray_t_p: Interval) bool {
    var ray_t = ray_t_p;
    for (0..3) |axis| {
        const ax = self.axisInterval(axis);
        const adinv = 1.0 / r.dir.data[ax];
        
        const t0 = (ax.min - r.orig.data[axis]) * adinv;
        const t1 = (ax.max - r.orig.data[axis]) * adinv;
        
        if (t0 < t1) {
            if (t0 > ray_t.min) ray_t.min = t0;
            if (t1 < ray_t.max) ray_t.max = t1;
        } else {
            if (t1 > ray_t.min) ray_t.min = t1;
            if (t0 < ray_t.max) ray_t.max = t0;
        }
        
        if (ray_t.max <= ray_t.min) {
            return false;
        }
    }
    return true;
}
