const std = @import("std");

pub fn stdout(io: std.Io, comptime msg: []const u8, args: anytype) !void {
    var stdout_writer = std.Io.File.stdout().writer(io, &.{});
    const stdout_interface = &stdout_writer.interface;

    try stdout_interface.print(msg, args);
    try stdout_interface.flush();
}

pub fn stderr(io: std.Io, comptime msg: []const u8, args: anytype) !void {
    var stderr_writer = std.Io.File.stderr().writer(io, &.{});
    const stderr_interface = &stderr_writer.interface;

    try stderr_interface.print(msg, args);
    try stderr_interface.flush();
}
