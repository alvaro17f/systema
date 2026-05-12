const std = @import("std");

pub fn getUsername(environ_map: std.process.Environ.Map) []const u8 {
    return environ_map.get("USER") orelse return "NO_USER_NAME_FOUND";
}
