const std = @import("std");
const zon = @import("zon");
const detectLeaks = @import("utils").allocator.detectLeaks;
const app = @import("app/init.zig");

pub const Config = struct {
    name: []const u8,
    version: []const u8,
    logo: bool = true,
    // logo_color: @TypeOf(Colors),
    logo_path: []const u8 = "",
    logo_gap: u8 = 3,
    info_offset: u8 = 0,
};

pub fn main() !void {
    defer if (detectLeaks()) {
        std.posix.exit(1);
    };

    const config = Config{
        .name = @tagName(zon.name),
        .version = zon.version,
    };

    try app.init(&config);
}
