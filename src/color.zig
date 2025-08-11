const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Interval = @import("Interval.zig");

pub const Color = Vec3;

const intensity = Interval{.min = 0.000, .max = 0.999};

/// first argument is a writer
pub fn writeColor(writer: anytype, color: Color) !void {
    const r, const g, const b = color.data;

    const rbyte: u16 = @intFromFloat(256 * intensity.clamp(r));
    const gbyte: u16 = @intFromFloat(256 * intensity.clamp(g));
    const bbyte: u16 = @intFromFloat(256 * intensity.clamp(b));

    try writer.print("{} {} {}\n", .{rbyte, gbyte, bbyte});
}
