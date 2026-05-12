const std = @import("std");
const lineFinder = @import("utils").lineFinder.lineFinder;

pub fn getCpuInfo(allocator: std.mem.Allocator, io: std.Io) []const u8 {
    return lineFinder(allocator, io, "/proc/cpuinfo", "model name", ':') catch "Unknown";
}
