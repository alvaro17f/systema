const std = @import("std");

pub fn getDesktop(allocator: std.mem.Allocator, environ_map: std.process.Environ.Map) ![]const u8 {
    const desktop_env = environ_map.get("XDG_CURRENT_DESKTOP") orelse "Unknown";
    const session_env = environ_map.get("XDG_SESSION_TYPE") orelse "Unknown";

    return std.fmt.allocPrint(allocator, "{s} ({s})", .{ desktop_env, session_env });
}
