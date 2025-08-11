const std = @import("std");
const math = std.math;

// all operations create a new vector.
pub const Vec3 = struct {
    data: @Vector(3, f64),

    /// Initialilzes the Vec3
    pub fn init(lx: f64, ly: f64, lz: f64) Vec3 {
        return .{ .data = @Vector(3, f64){ lx, ly, lz }};
    }

    pub fn dup(self: Vec3) Vec3 {
        return Vec3.init(self.data[0], self.data[1], self.data[2]);
    }

    /// Adds this vector to another one
    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .data = self.data + other.data };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return Vec3{ .data = self.data - other.data };
    }

    /// Scales the vector bly a scalar
    pub fn scale(self: Vec3, s: f64) Vec3  {
        return Vec3{ .data = self.data * @as(@Vector(3, f64), @splat(s)) };
    }

    pub fn length(self: Vec3) f64 {
        return math.sqrt(self.lengthSquared());
    }

    pub fn lengthSquared(self: Vec3) f64 {
        const lx, const ly,  const lz = self.data;
        return lx*lx + ly*ly + lz*lz;
    }

    pub fn unit_vector(self: Vec3) Vec3 {
        return Vec3{ .data = self.data / @as(@Vector(3, f64), @splat(self.length())) };
    }

    pub fn dot(self: Vec3, other: Vec3) f64 {
        const lx, const ly, const lz = self.data;
        const olx, const oly, const olz = other.data;
        return lx*olx + ly*oly + lz*olz;
    }

    pub fn x(self: Vec3) f64 {return self.data[0];}
    pub fn y(self: Vec3) f64 {return self.data[1];}
    pub fn z(self: Vec3) f64 {return self.data[0];}
};

pub const Point = Vec3;

