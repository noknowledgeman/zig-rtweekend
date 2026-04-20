const std = @import("std");
const Interval = @import("Interval.zig");
const Vec3 = @import("vec3.zig").Vec3;
const Point = @import("vec3.zig").Point;
const Ray = @import("Ray.zig");

/// The Axis=aligned boundinng box class, can be initialized as  a struct
const AaBb = @This();

pub const empty: AaBb = .{};
pub const universe: AaBb = .{
    .x = Interval.universe,
    .y = Interval.universe,
    .z = Interval.universe,
};

x: Interval = .{},
y: Interval = .{},
z: Interval = .{},

pub fn initWithPoints(a: Point, b: Point) AaBb {
    const x = if (a.x() <= b.x()) Interval.init(a.x(), b.x()) else Interval.init(b.x(), a.x());
    const y = if (a.y() <= b.y()) Interval.init(a.y(), b.y()) else Interval.init(b.y(), a.y());
    const z = if (a.z() <= b.z()) Interval.init(a.z(), b.z()) else Interval.init(b.z(), a.z());
    
    var aabb = AaBb{.x = x, .y = y, .z = z};
    
    aabb.padToMinimums();
    
    return aabb;
}

pub fn combine(a: AaBb, b: AaBb) AaBb {
    const new: AaBb = .{
        .x =  Interval.combine(a.x, b.x),
        .y =  Interval.combine(a.y, b.y),
        .z =  Interval.combine(a.z, b.z),
    };
    
    return new;
}

pub fn axisInterval(self: AaBb, n: u32) Interval {
    return switch (n) {
        0 => self.x,
        1 => self.y,
        2 => self.z,
        else => unreachable,
    };
} 

pub fn hit(self: AaBb, r: Ray, ray_t: Interval) bool {
    var ray_tc = ray_t;
    const ray_orig = r.orig;
    const ray_dir = r.dir;
    
    for (0..3) |axis| {
        const ax = self.axisInterval(@intCast(axis));
        const adinv = 1.0/ray_dir.axis(@intCast(axis));
        
        const t0 = (ax.min - ray_orig.axis(@intCast(axis))) * adinv;
        const t1 = (ax.max - ray_orig.axis(@intCast(axis))) * adinv;
        
        if (t0 < t1) {
            if (t0 > ray_tc.min) ray_tc.min = t0;
            if (t1 < ray_tc.max) ray_tc.max = t1;
        } else {
            if (t1 > ray_tc.min) ray_tc.min = t1;
            if (t0 < ray_tc.max) ray_tc.max = t0;
        }
        
        if (ray_tc.max <= ray_tc.min) {
            return false;
        }
    }
    return true;
}

fn padToMinimums(self: *AaBb) void {
    const delta = 0.0001;
    
    if (self.x.size() < delta) self.x = self.x.expand(delta);
    if (self.y.size() < delta) self.y = self.y.expand(delta);
    if (self.z.size() < delta) self.z = self.z.expand(delta);
}

pub fn longestAxis(self: AaBb) u32 {
    if (self.x.size() > self.y.size()) {
        return if (self.x.size() > self.z.size()) 0 else 2;
    }
    else {
        return if (self.y.size() > self.z.size()) 1 else 2;
    }
}