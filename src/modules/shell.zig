const std = @import("std");

pub fn getShell(allocator: std.mem.Allocator) ![]const u8 {
    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();

    if (env_map.get("SHELL")) |shell_path| {
        var shell_it = std.mem.tokenizeScalar(u8, shell_path, '/');
        var shell: []const u8 = undefined;
        while (shell_it.next()) |split| {
            shell = split;
        }

        return try allocator.dupe(u8, shell);
    }

    return "Unknown";
}
