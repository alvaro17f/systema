const std = @import("std");

const Desktop = struct {
    desktop: []const u8,
    session: []const u8,
};

pub fn getDesktop(allocator: std.mem.Allocator) ![]const u8 {
    const desktop_env = std.posix.getenv("XDG_CURRENT_DESKTOP") orelse "Unknown";
    const session_env = std.posix.getenv("XDG_SESSION_TYPE") orelse "Unknown";

    const desktop = Desktop{
        .desktop = desktop_env,
        .session = session_env,
    };

    return std.fmt.allocPrint(allocator, "{s} ({s})", .{ desktop.desktop, desktop.session });
}
