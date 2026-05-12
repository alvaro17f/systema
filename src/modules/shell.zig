const std = @import("std");

pub fn getShell(allocator: std.mem.Allocator, environ_map: std.process.Environ.Map) ![]const u8 {
    if (environ_map.get("SHELL")) |shell_path| {
        var shell_it = std.mem.tokenizeScalar(u8, shell_path, '/');
        var shell: []const u8 = undefined;
        while (shell_it.next()) |split| {
            shell = split;
        }

        return try allocator.dupe(u8, shell);
    }

    return "Unknown";
}
