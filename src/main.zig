const std = @import("std");
const zon = @import("zon");
const Allocator = @import("utils").allocator;
const Modules = @import("modules");

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
    defer if (Allocator.detectLeaks()) {
        std.posix.exit(1);
    };

    const config = Config{
        .name = @tagName(zon.name),
        .version = zon.version,
    };

    try init(&config);
}

pub fn init(config: *const Config) !void {
    var modules = try Modules.init(Allocator.allocator);
    defer modules.deinit();

    try Modules.print(config, modules);
}
