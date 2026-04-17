const std = @import("std");

const Interval = @import("Interval.zig");

pub fn degreesToRadians(degrees: f64) f64 {
    return degrees * std.math.pi / 180;
}

var rand: ?std.Random.Xoshiro256 = null;

fn initRand() void {
    // set seed for now to remove any os dependencies
    rand = std.Random.DefaultPrng.init(1);
}

pub fn randomDouble() f64 {
    if (rand == null) initRand();
    return rand.?.random().float(f64);
}

pub fn randomInt(min: u32, max: u32) u32 {
    if (rand == null) initRand();
    return (rand.?.random().int(u32)%(max-min+1)) + min;
}

pub fn randomDoubleInterval(int: Interval) f64 {
    return int.min + (int.max-int.min)*randomDouble();
}

pub fn createInit(allocator: std.mem.Allocator, comptime T: type, props: T) !*T {
    const new = try allocator.create(T);
    new.* = props;
    return new;
}
