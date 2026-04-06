const std = @import("std");
const math = std.math;

const Interval = @import("Interval.zig");
const util = @import("util.zig");

// all operations create a new vector.
pub const Vec3 = struct {
    data: @Vector(3, f64),
    
    pub const zero: Vec3 = .init(0, 0, 0);
    
    /// Initialilzes the Vec3
    pub fn init(lx: f64, ly: f64, lz: f64) Vec3 {
        return .{ .data = @Vector(3, f64){ lx, ly, lz }};
    }

    /// Adds this vector to another one
    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .data = self.data + other.data };
    }

    /// Multiplies the vector by element.
    pub fn mul(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .data = self.data * other.data };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .data = self.data - other.data };
    }

    /// Scales the vector bly a scalar
    pub fn scale(self: Vec3, s: f64) Vec3  {
        return Vec3{ .data = self.data * @as(@Vector(3, f64), @splat(s)) };
    }

    pub fn length(self: Vec3) f64 {
        return @sqrt(self.lengthSquared());
    }

    pub fn lengthSquared(self: Vec3) f64 {
        const lx, const ly,  const lz = self.data;
        return lx*lx + ly*ly + lz*lz;
    }

    pub fn unitVector(self: Vec3) Vec3 {
        return Vec3{ .data = self.data / @as(@Vector(3, f64), @splat(self.length())) };
    }

    pub fn dot(self: Vec3, other: Vec3) f64 {
        const lx, const ly, const lz = self.data;
        const olx, const oly, const olz = other.data;
        return lx*olx + ly*oly + lz*olz;
    }

    pub fn nearZero(self: Vec3) bool {
        const s = 1e-8;
        return (@abs(self.data[0]) < s) and (@abs(self.data[1]) < s) and (@abs(self.data[2]) < s);
    }

    pub fn reflect(self: Vec3, n: Vec3) Vec3 {
        return self.sub(n.scale(2*n.dot(self)));
    }

    pub fn refract(uv: Vec3, n: Vec3, etai_over_etat: f64) Vec3 {
        const cos_theta = @min(uv.scale(-1).dot(n), 1.0);
        const r_out_perp = uv.add(n.scale(cos_theta)).scale(etai_over_etat);
        const r_out_parallel = n.scale(-1*@sqrt(@abs(1.0 - r_out_perp.lengthSquared())));

        return r_out_perp.add(r_out_parallel);
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return .{
            .data = @Vector(3, f64){
                self.data[1]*other.data[2] - self.data[2]*other.data[1],
                self.data[2]*other.data[0] - self.data[0]*other.data[2],
                self.data[0]*other.data[1] - self.data[1]*other.data[0],
            },
        };
    }

    pub fn x(self: Vec3) f64 {return self.data[0];}
    pub fn y(self: Vec3) f64 {return self.data[1];}
    pub fn z(self: Vec3) f64 {return self.data[2];}

    pub fn randomUnitVector() Vec3 {
        while (true) {
            const p = randomInterval(Interval{.min = -1, .max = 1});
            const lensq = p.lengthSquared();
            if (1e-160 < lensq and  lensq <= 1) {
                return p.scale(1/@sqrt(lensq));
            }
        }
    }

    pub fn random() Vec3 {
        return Vec3.init(util.randomDouble(), util.randomDouble(), util.randomDouble());
    }

    pub fn randomInterval(interval: Interval) Vec3 {
        return Vec3.init(util.randomDoubleInterval(interval), util.randomDoubleInterval(interval), util.randomDoubleInterval(interval));

    }

    pub fn randomVectorOnHemisphere(normal: Vec3) Vec3 {
        const on_unit_sphere = randomUnitVector();
        if (on_unit_sphere.dot(normal) > 0.0) {
            return on_unit_sphere;
        } else {
            return on_unit_sphere.scale(-1);
        }
    }

    pub fn randomVectorInUnitDisc() Vec3 {
        const int = Interval{ .min = -1, .max = 1};
        while (true) {
            const p = Vec3.init(util.randomDoubleInterval(int), util.randomDoubleInterval(int), 0.0);
            if (p.lengthSquared() < 1) {
                return p;
            }
        }
    }

};

pub const Point = Vec3;

