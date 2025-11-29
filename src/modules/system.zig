const std = @import("std");
const lineFinder = @import("utils").lineFinder.lineFinder;

pub fn getSystemInfo(allocator: std.mem.Allocator) []const u8 {
    const system_raw = lineFinder(allocator, "/etc/os-release", "PRETTY_NAME", '=') catch "Unkown";
    const trimmed = std.mem.trim(u8, system_raw, "\"");
    const result = allocator.dupe(u8, trimmed) catch unreachable;
    allocator.free(system_raw);
    return result;
}
