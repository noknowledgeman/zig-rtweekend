const std = @import("std");
const Interval = @import("Interval.zig");

pub fn degreesToRadians(degrees: f64) f64 {
    return degrees * std.math.pi / 180;
}

var rand = std.crypto.random;
pub fn randomDouble() f64 {
    return rand.float(f64);
}

pub fn randomDoubleInterval(int: Interval) f64 {
    return int.min + int.max*randomDouble();
}
