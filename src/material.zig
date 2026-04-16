const std = @import("std");
const HitRecord = @import("hittable.zig").HitRecord;
const Ray = @import("Ray.zig");
const Color = @import("color.zig").Color;
const Vec3 = @import("vec3.zig").Vec3;
const util = @import("util.zig");

// switching to an enum as it is easier to stack allocate
// Maybe in the future if this is a full library switch back for runtime polymorphism and extension of this type but right now thats
// wishful thinking
pub const Material = union(enum) {
    const Metallic = struct {
        albedo: Color,
        fuzz: f64,
    };

    /// contains the albedo
    lambertian: Color,
    metallic: Metallic,
    /// Contains the refraction_index
    dielectric: f64,
    zero,

    pub fn scatter(self: Material, ray: Ray, hit_record: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        switch (self) {
            .lambertian => |albedo| return scatterLambertian(albedo, ray, hit_record, attenuation, scattered),
            .metallic => |m| return scatterMetallic(m, ray, hit_record, attenuation, scattered),
            .zero => return false,
            .dielectric => |refraction_index| return scatterDielectric(refraction_index, ray, hit_record, attenuation, scattered),
        }
    }

    fn scatterLambertian(albedo: Color, ray: Ray, hit_record: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        _ = ray;

        var scatter_direction = hit_record.normal.add(Vec3.randomUnitVector());

        if (scatter_direction.nearZero()) {
            scatter_direction = hit_record.normal;
        }

        scattered.* = Ray.init(hit_record.p, scatter_direction);

        attenuation.* = albedo;

        return true;
    }

    fn scatterMetallic(self: Metallic, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        var reflected = r_in.dir.reflect(rec.normal);
        reflected = reflected.unitVector().add(Vec3.randomUnitVector().scale(self.fuzz));
        scattered.* = Ray.init(rec.p, reflected);
        attenuation.* = self.albedo;

        return scattered.dir.dot(rec.normal) > 0;
    }

    fn scatterDielectric(refraction_index: f64, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        attenuation.* = Color.init(1.0, 1.0, 1.0);
        const ri = if (rec.front_face) (1.0 / refraction_index) else refraction_index;

        const unit_direction = r_in.dir;

        const cos_theta = @min(unit_direction.scale(-1.0).dot(rec.normal), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

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
    
    fn reflectance(cosine: f64, refraction_index: f64) f64 {
        var r0 = (1 - refraction_index) / (1 + refraction_index);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f64, (1 - cosine), 5);
    }
};
