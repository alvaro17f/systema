const std = @import("std");

pub fn getKernelInfo(allocator: std.mem.Allocator) []const u8 {
    const uname = std.posix.uname();

    const sysname = std.mem.sliceTo(&uname.sysname, 0);
    const release = std.mem.sliceTo(&uname.release, 0);
    const machine = std.mem.sliceTo(&uname.machine, 0);

    return std.fmt.allocPrint(allocator, "{s} {s} ({s})", .{ sysname, release, machine }) catch "unknown";
}
