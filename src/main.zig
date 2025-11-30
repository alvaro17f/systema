const std = @import("std");
const Allocator = @import("utils").allocator;
const Colors = @import("utils").colors;
const Modules = @import("modules");
const log = std.log.scoped(.main);
const zon = @import("zon");

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
    log.debug("{s}***** DEBUG BUILD *****{s}", .{ Colors.RED, Colors.RESET });

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
