const std = @import("std");
const Allocator = @import("utils").allocator;
const fmt = @import("utils").fmt;
const Colors = @import("utils").colors;
const Modules = @import("modules");
const log = std.log.scoped(.main);
const zon = @import("zon");

pub const Logo = struct {
    enabled: bool = true,
    embed: []const u8 = @embedFile("assets/logo"),
    path: ?[]const u8 = null,
    color: []const u8 = Colors.BLUE,
    gap: u8 = 3,
};

pub const Icons = struct {
    color: []const u8 = Colors.BLUE,
};

pub const Info = struct {
    color: []const u8 = Colors.BLUE,
    offset: u8 = 0,
};

pub const Config = struct {
    name: []const u8,
    version: []const u8,
    logo: Logo = Logo{},
    icons: Icons = Icons{},
    info: Info = Info{},
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

    var arena: Allocator.Arena = undefined;
    arena.init();
    defer arena.deinit();

    var modules: Modules = undefined;
    try modules.init(arena.allocator());

    try cli(config);
    try Modules.print(&config, modules);

    log.debug("{s}***** {s}{s}{s}: {s}{s}{s} *****{s}", .{ Colors.RED, Colors.YELLOW, config.name, Colors.RESET, Colors.GREEN, config.version, Colors.RED, Colors.RESET });
}

pub fn cli(config: Config) !void {
    _ = config;
    // try fmt.print("{s} version: {s}\n", .{ config.name, config.version });
}
