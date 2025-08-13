const std = @import("std");
const HitRecord = @import("hittable.zig").HitRecord;
const Ray = @import("Ray.zig");
const Color = @import("color.zig").Color;
const Vec3 = @import("vec3.zig").Vec3;

pub const empty: Material = undefined;

pub const Material = struct {
    ptr: *anyopaque,
    scatterFn: *const fn(ptr: *anyopaque, ray: Ray, hit_record: HitRecord, attenuation: *Color, scattered: *Ray) bool,

    pub fn scatter(self: *Material, ray: Ray, hit_record: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        return self.scatterFn(self.ptr, ray, hit_record, attenuation, scattered);
    }
};

pub const Lambertian = struct {
    albedo: Color,

    // TODO: maybe add init but this is pretty straight forward so It can just be initialized

    fn scatter(ptr: *anyopaque, ray: Ray, hit_record: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        _ = ray;
        const self: *Lambertian = @ptrCast(@alignCast(ptr));

        var scatter_direction = hit_record.normal.add(Vec3.randomUnitVector());

        if (scatter_direction.nearZero()) {
            scatter_direction = hit_record.normal;
        }

        scattered.* = Ray.init(hit_record.p, scatter_direction);

        attenuation.* = self.albedo;

        return true;
    }

    pub fn material(self: *Lambertian) Material {
        return .{
            .ptr = self,
            .scatterFn = scatter,
        };
    }
};

pub const Metallic = struct {
    albedo: Color,
    fuzz: f64,

    fn scatter(ptr: *anyopaque, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const self: *Metallic = @ptrCast(@alignCast(ptr));

        var reflected = r_in.dir.reflect(rec.normal);
        reflected = reflected.unitVector().add(Vec3.randomUnitVector().scale(self.fuzz));
        scattered.* = Ray.init(rec.p, reflected);
        attenuation.* = self.albedo;

        return scattered.dir.dot(rec.normal) > 0;
    }

    pub fn material(self: *Metallic) Material {
        return .{
            .ptr = self,
            .scatterFn = scatter,
        };
    }
};
