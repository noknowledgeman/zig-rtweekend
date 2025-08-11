const std = @import("std");
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point = vec3.Point;

const Ray = @This();

orig: Point,
dir: Vec3,

pub fn init(orig: Point, dir: Vec3) Ray {
    return .{
        .orig = orig,
        .dir = dir,
    };
}

pub fn at(self: Ray, t: f64 ) Point {
    return self.orig.add(self.dir.scale(t));
}
