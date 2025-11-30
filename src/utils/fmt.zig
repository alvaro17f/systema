const std = @import("std");

pub fn print(comptime msg: []const u8, args: anytype) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print(msg, args);

    try stdout.flush(); // Don't forget to flush!
}

pub fn stderr(comptime msg: []const u8, args: anytype) !void {
    var stderr_buffer: [1024]u8 = undefined;
    var stderr_writer = std.fs.File.stdout().writer(&stderr_buffer);
    const stderr_interface = &stderr_writer.interface;

    try stderr_interface.print(msg, args);

    try stderr_interface.flush(); // Don't forget to flush!
}
