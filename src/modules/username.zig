const std = @import("std");

pub fn getUsername() []const u8 {
    return std.posix.getenv("USER") orelse return "NO_USER_NAME_FOUND";
}
