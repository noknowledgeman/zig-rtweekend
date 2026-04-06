const std = @import("std");
const HitRecord = @import("hittable.zig").HitRecord;
const Hittable = @import("hittable.zig").Hittable;
const Interval = @import("Interval.zig");
const Material = @import("material.zig").Material;
const Point = @import("vec3.zig").Point;
const Ray = @import("Ray.zig");
const Vec3 = @import("vec3.zig").Vec3;
const AaBb = @import("AaBb.zig");

const Sphere = @This();

radius: f64,
center: Point,
mat: Material,
bbox: AaBb = .{},

pub fn init(center: Point, radius: f64, mat: Material) Sphere {
    const rvec = Vec3.init(radius, radius, radius);
    const bbox: AaBb = .initWithPoints(center.sub(rvec), center.add(rvec));
    return .{
        .center = center,
        .radius = @max(0, radius),
        .mat = mat,
        .bbox = bbox,
    };
}

fn hit(ptr: *anyopaque, ray: Ray, ray_t: Interval, rec: *HitRecord) bool { 
    const self: *Sphere = @ptrCast(@alignCast(ptr));

    const oc = self.center.sub(ray.orig);

    const a: f64 = ray.dir.lengthSquared();
    const h: f64 = ray.dir.dot(oc);
    const c: f64 = oc.lengthSquared() - self.radius*self.radius;

    const discriminant: f64 = h*h - a*c;
    if (discriminant < 0) {
        return false;
    }

    const sqrtd: f64 = @sqrt(discriminant);

    var root: f64 = (h - sqrtd) / a;
    if (!ray_t.surrounds(root)) {
        root = (h + sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            return false;
        }
    }

    rec.t = root;
    rec.p = ray.at(rec.t);
    const outward_normal = self.normalAtPoint(rec.p);
    rec.setFaceNormal(ray, outward_normal);
    rec.mat = self.mat;

    return true;
}

fn boundingBox(ptr: *anyopaque) AaBb {
    const self: *Sphere = @ptrCast(@alignCast(ptr));
    return self.bbox;
}

pub fn hittable(self: *Sphere) Hittable {
    return .{
        .ptr = self,
        .hitFn = hit,
        .boundingBoxFn = boundingBox,
    };
}

/// Finds the normal at a point, does not check if the point is on the sphere that is assumed
pub inline fn normalAtPoint(self: Sphere, pnt: Point) Vec3 {
    return pnt.sub(self.center).scale(1.0/self.radius);
}


