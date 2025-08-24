const std = @import("std");
const color = @import("color.zig");
const Color = @import("color.zig").Color;
const Interval = @import("Interval.zig");

const Buffer = @This();

const EndOfBuffer = error{EndOfbuffer};


mutex: std.Thread.Mutex = .{},
buf: std.ArrayList(u8),
x: u32,
y: u32,
allocator: std.mem.Allocator,

const Error = error{
    BufferTooSmall,
};

pub fn init(allocator: std.mem.Allocator, x: u32, y: u32) !Buffer {
    return .{
        .buf = try std.ArrayList(u8).initCapacity(allocator, 3*x*y),
        .x = x,
        .y = y,
        .allocator = allocator,
    };
}

pub fn appendColor(self: *Buffer, col: Color) !void {
    try self.buf.appendSlice(color.colorToBytes(col)[0..]);
}

pub fn insertColor(self: *Buffer, col: Color, x: usize, y: usize) !void {
    self.mutex.lock();
    defer self.mutex.unlock();
    try self.buf.insertSlice(3*(y*self.x + x), color.colorToBytes(col)[0..]);
}

pub fn deinit(self: *Buffer) void {
    self.allocator.free(self.buf);
}

fn convertToBuffer(self: Buffer, buf: []u8) Error!void {
    if (self.x*self.y*3 > buf.len) {
        return Error.BufferTooSmall;
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
