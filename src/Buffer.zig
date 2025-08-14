const std = @import("std");
const color = @import("color.zig");
const Color = @import("color.zig").Color;
const Interval = @import("Interval.zig");

const Buffer = @This();

const EndOfBuffer = error{EndOfbuffer};

buf: std.ArrayList(Color),
x: u32,
y: u32,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator, x: u32, y: u32) !Buffer {
    return .{
        .buf = try std.ArrayList(Color).initCapacity(allocator, x*y),
        .x = x,
        .y = y,
        .allocator = allocator,
    };
}

pub fn appendColor(self: *Buffer, col: Color) !void {
    try self.buf.append(col);
}

/// Tries to resize the buffer, will error if refused
pub fn resize(self: *Buffer, x: u32, y: u32) !void {
    self.x = x;
    self.y = y;
    if (!self.buf.resize(x*y)) {
        return std.mem.Allocator.Error;
    }
}

pub fn deinit(self: *Buffer) void {
    self.allocator.free(self.buf);
}

pub fn writeAsPPM(self: Buffer, file_name: []const u8) !void {
    const file = try std.fs.cwd().createFile(file_name, .{.read = true});
    defer file.close();
    const writer = file.writer();

    try writer.print("P3\n{}\n{}\n255\n", .{self.x, self.y});

    const intensity = Interval{.min = 0.000, .max = 0.999};
    for (self.buf.items) |c| {
        var r, var g, var b = c.data;

        r = color.linearToGamma(r);
        g = color.linearToGamma(g);
        b = color.linearToGamma(b);

        const rbyte: u16 = @intFromFloat(256 * intensity.clamp(r));
        const gbyte: u16 = @intFromFloat(256 * intensity.clamp(g));
        const bbyte: u16 = @intFromFloat(256 * intensity.clamp(b));

        try writer.print("{} {} {}\n", .{rbyte, gbyte, bbyte});
    }
}
