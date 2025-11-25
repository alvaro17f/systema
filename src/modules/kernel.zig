const std = @import("std");

pub fn getKernelInfo(allocator: std.mem.Allocator) []const u8 {
    const uname = std.posix.uname();
    return std.fmt.allocPrint(allocator, "{s} {s} ({s})", .{ uname.sysname, uname.release, uname.machine }) catch unreachable;
}
