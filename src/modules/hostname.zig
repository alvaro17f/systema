const std = @import("std");

pub fn getHostname(hostname_buf: *[std.posix.HOST_NAME_MAX]u8) []const u8 {
    return std.posix.gethostname(hostname_buf) catch return "NO_HOST_NAME_FOUND";
}
