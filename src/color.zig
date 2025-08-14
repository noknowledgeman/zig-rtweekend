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

// const intensity = Interval{ .min = 0.000, .max = 0.999 };
// pub fn writeColor(writer: anytype, pixel_color: Color) !void {
//     var r, var g, var b = pixel_color.data;
//
//     r = linearToGamma(r);
//     g = linearToGamma(g);
//     b = linearToGamma(b);
//
//     const rbyte: u8 = @intFromFloat(256 * intensity.clamp(r));
//     const gbyte: u8 = @intFromFloat(256 * intensity.clamp(g));
//     const bbyte: u8 = @intFromFloat(256 * intensity.clamp(b));
//
//     try writer.print("{} {} {}\n", .{rbyte, gbyte, bbyte});
// }
