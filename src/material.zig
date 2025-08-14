const std = @import("std");
const HitRecord = @import("hittable.zig").HitRecord;
const Ray = @import("Ray.zig");
const Color = @import("color.zig").Color;
const Vec3 = @import("vec3.zig").Vec3;
const util = @import("util.zig");

pub const Material = struct {
    ptr: *anyopaque,
    scatterFn: *const fn(ptr: *anyopaque, ray: Ray, hit_record: HitRecord, attenuation: *Color, scattered: *Ray) bool,

    pub fn scatter(self: *Material, ray: Ray, hit_record: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        return self.scatterFn(self.ptr, ray, hit_record, attenuation, scattered);
    }
};

pub const Lambertian = struct {
    albedo: Color,

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

pub const Dielectric = struct {
    refraction_index: f64,

    fn scatter(ptr: *anyopaque, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const self: *Dielectric = @ptrCast(@alignCast(ptr));

        attenuation.* = Color.init(1.0, 1.0, 1.0);
        const ri = if (rec.front_face) (1.0/self.refraction_index) else self.refraction_index;

        // NOTE: Following the tutorial but should not be necessary.
        const unit_direction = r_in.dir.unitVector();

        const cos_theta = @min(unit_direction.scale(-1.0).dot(rec.normal), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta*cos_theta);

        const cannot_refract = (ri * sin_theta) > 1.0;
        var direction: Vec3 = undefined;

        if (cannot_refract or (reflectance(cos_theta, ri) > util.randomDouble())) {
            direction = unit_direction.reflect(rec.normal);
        } else {
            direction = unit_direction.refract(rec.normal, ri);
        }

        scattered.* = Ray.init(rec.p, direction);
        return true;
    }

    pub fn material(self: *Dielectric) Material {
        return .{
            .ptr = self,
            .scatterFn = scatter,
        };
    }

    fn reflectance(cosine: f64, refraction_index: f64) f64 {
        var r0 = (1 - refraction_index)/(1 + refraction_index);
        r0 = r0*r0;
        return r0 + (1-r0)*std.math.pow(f64, (1-cosine), 5);
    }
};
