const std = @import("std");
const lineFinder = @import("utils").lineFinder.lineFinder;

pub fn getCpuInfo(allocator: std.mem.Allocator) []const u8 {
    return lineFinder(allocator, "/proc/cpuinfo", "model name", ':') catch "Unknown";
}
