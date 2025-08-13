const std = @import("std");
const Interval = @import("Interval.zig");

pub fn degreesToRadians(degrees: f64) f64 {
    return degrees * std.math.pi / 180;
}

// TODO: Make the seed random
var rand = std.Random.DefaultPrng.init(1);
pub fn randomDouble() f64 {
    return rand.random().float(f64);
}

pub fn randomDoubleInterval(int: Interval) f64 {
    return int.min + (int.max-int.min)*randomDouble();
}
