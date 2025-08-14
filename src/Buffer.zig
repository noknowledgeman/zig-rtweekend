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

    try writer.print("P6\n{}\n{}\n255\n", .{self.x, self.y});

    const byte_buffer: []u8 = try self.allocator.alloc(u8, self.x*self.y*3);
    defer self.allocator.free(byte_buffer);

    const intensity = Interval{.min = 0.000, .max = 0.999};
    for (self.buf.items, 0..) |c, ind| {
        var r, var g, var b = c.data;

        r = color.linearToGamma(r);
        g = color.linearToGamma(g);
        b = color.linearToGamma(b);

        const rbyte: u8 = @intFromFloat(256 * intensity.clamp(r));
        const gbyte: u8 = @intFromFloat(256 * intensity.clamp(g));
        const bbyte: u8 = @intFromFloat(256 * intensity.clamp(b));

        byte_buffer[3*ind] = rbyte;
        byte_buffer[3*ind+1] = gbyte;
        byte_buffer[3*ind+2] = bbyte;
    }
    _ = try writer.write(byte_buffer);
}
