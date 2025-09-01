const std = @import("std");

const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;
const Point = vec3.Point;

const Ray = @This();

orig: Point,
dir: Vec3,
tm: f64 = 0,

pub fn initTm(orig: Point, dir: Vec3, tm: f64) Ray {
    return .{
        .orig = orig, 
        .dir =  dir.unitVector(),
        .tm = tm,
    };
}

pub fn init(orig: Point, dir: Vec3) Ray {
    return .{
        .orig = orig,
        .dir = dir.unitVector(),
        .tm = 0,
    };
}

pub fn at(self: Ray, t: f64) Point {
    return self.orig.add(self.dir.scale(t));
}
