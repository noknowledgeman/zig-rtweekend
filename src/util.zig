const std = @import("std");

const Interval = @import("Interval.zig");

pub fn degreesToRadians(degrees: f64) f64 {
    return degrees * std.math.pi / 180;
}

var rand: ?std.Random.Xoshiro256 = null;
pub fn randomDouble() f64 {
    if (rand == null) {
        rand  = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
    }
    return rand.?.random().float(f64);
}

pub fn randomDoubleInterval(int: Interval) f64 {
    return int.min + (int.max-int.min)*randomDouble();
}

pub fn createInit(allocator: std.mem.Allocator, comptime T: type, props: anytype) T {
    const new = allocator.create(T);
    new.* = props;
    return new;
}
