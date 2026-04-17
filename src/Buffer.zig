const std = @import("std");

const color = @import("color.zig");
const Color = @import("color.zig").Color;

const Buffer = @This();

buf: []u8,
x: u32,
y: u32,
allocator: std.mem.Allocator,

const Error = error{
    BufferTooSmall,
};

pub fn init(allocator: std.mem.Allocator, x: u32, y: u32) !Buffer {
    return .{
        .buf = try allocator.alloc(u8, 4*x*y),
        .x = x,
        .y = y,
        .allocator = allocator,
    };
}

pub fn insertColor(self: *Buffer, col: Color, x: usize, y: usize) !void {
    if (4*(y*self.x + x) + 3 >= self.buf.len) {
        return Error.BufferTooSmall;
    }
    
    // rgba for now
    const bytes = color.colorToBytes(col);
    const idx = 4 * (y * self.x + x);
    self.buf[idx + 0] = bytes[0];
    self.buf[idx + 1] = bytes[1];
    self.buf[idx + 2] = bytes[2];
    self.buf[idx + 3] = 255;
}

pub fn deinit(self: *Buffer) void {
    self.allocator.free(self.buf);
}

pub fn writeAsPPM(self: Buffer, file_name: []const u8) !void {
    const file = try std.fs.cwd().createFile(file_name, .{.read = true});
    defer file.close();

    var writer = file.writer(&.{});
 
    // The binary ppm header
    try writer.interface.print("P6\n{}\n{}\n255\n", .{self.x, self.y});

    // just write the buffer
    _ = try writer.interface.write(self.buf);
}
