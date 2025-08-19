const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Interval = @import("Interval.zig");

pub const Color = Vec3;

pub inline fn linearToGamma(linear_component: f64) f64 {
    if (linear_component > 0.0) {
        return @sqrt(linear_component);
    }

    return 0.0;
}

