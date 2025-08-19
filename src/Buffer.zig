const std = @import("std");
const color = @import("color.zig");
const Color = @import("color.zig").Color;
const Interval = @import("Interval.zig");

const Buffer = @This();

const EndOfBuffer = error{EndOfbuffer};


buf: std.ArrayList(u8),
x: u32,
y: u32,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator, x: u32, y: u32) !Buffer {
    return .{
        .buf = try std.ArrayList(u8).initCapacity(allocator, x*y),
        .x = x,
        .y = y,
        .allocator = allocator,
    };
}

pub fn appendColor(self: *Buffer, col: Color) !void {
    var r, var g, var b = col.data;

    r = color.linearToGamma(r);
    g = color.linearToGamma(g);
    b = color.linearToGamma(b);

    const intensity = Interval{.min = 0.000, .max = 0.999};
    const rbyte: u8 = @intFromFloat(256 * intensity.clamp(r));
    const gbyte: u8 = @intFromFloat(256 * intensity.clamp(g));
    const bbyte: u8 = @intFromFloat(256 * intensity.clamp(b));

    try self.buf.append(rbyte);
    try self.buf.append(gbyte);
    try self.buf.append(bbyte);
}

pub fn deinit(self: *Buffer) void {
    self.allocator.free(self.buf);
}

const Error = error{
    BufferTooSmall,
};

fn convertToBuffer(self: Buffer, buf: []u8) !void {
    if (self.x*self.y*3 > buf.len) {
        return error.BufferTooSmall;
    }

    @memcpy(buf, self.buf.items);
}

pub fn writeAsPPM(self: Buffer, file_name: []const u8) !void {
    const file = try std.fs.cwd().createFile(file_name, .{.read = true});
    defer file.close();

    const writer = file.writer();
 
    try writer.print("P6\n{}\n{}\n255\n", .{self.x, self.y});

    const byte_buffer: []u8 = try self.allocator.alloc(u8, self.x*self.y*3);
    defer self.allocator.free(byte_buffer);

    try self.convertToBuffer(byte_buffer);

    _ = try writer.write(byte_buffer);
}

// pub fn writeToKitty(self: Buffer) !void {
//     const stdout = std.io.getStdOut();
//     const writer = stdout.writer();
//
//
//
// }
