const std = @import("std");

const Interval = @This();

pub const empty: Interval = init(std.math.inf(f64), -std.math.inf(f64));
pub const universe: Interval = init(-std.math.inf(f64), std.math.inf(f64));

min: f64 = std.math.inf(f64),
max: f64 = -std.math.inf(f64),

pub fn init(min: f64, max: f64) Interval {
    return .{
        .min = min,
        .max = max,
    };
}

pub fn combine(a: Interval, b: Interval) Interval {
    return .{
        .min = @min(a.min, b.min),
        .max = @max(a.max, b.max),
    };
}

pub fn size(self: Interval) f64 {
    return self.max - self.min;
}

pub fn contains(self: Interval, x: f64) bool {
    return (self.min <= x) and (x <= self.max);
}

pub fn surrounds(self: Interval, x: f64) bool {
    return (self.min < x) and (x < self.max);
}

pub fn clamp(self: Interval, x: f64) f64 {
    if (x < self.min) return self.min;
    if (x > self.max) return self.max;
    return x;
}

pub fn expand(self: Interval, delta: f64) Interval {
    const padding = delta/2.0;
    return .{
        .min = self.min - padding,
        .max = self.max + padding,
    };
}
