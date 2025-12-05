const std = @import("std");
const Allocator = @import("utils").allocator;
const fmt = @import("utils").fmt;
const Colors = @import("utils").colors;
const Modules = @import("modules");
const log = std.log.scoped(.main);
const zon = @import("zon");
const Cli = @import("cli");

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

pub const Labels = struct {
    color: []const u8 = Colors.BLUE,
};

pub const Config = struct {
    name: []const u8,
    version: []const u8,
    logo: Logo = Logo{},
    icons: Icons = Icons{},
    labels: Labels = Labels{},
};

pub fn main() !void {
    defer if (Allocator.detectLeaks()) {
        std.posix.exit(1);
    };

    var config = Config{
        .name = @tagName(zon.name),
        .version = zon.version,
    };

    log.debug("{s}***** DEBUG BUILD: {s}{s}{s}: {s}{s}{s} *****{s}", .{ Colors.RED, Colors.YELLOW, config.name, Colors.RESET, Colors.GREEN, config.version, Colors.RED, Colors.RESET });

    var arena: Allocator.Arena = undefined;
    arena.init();
    defer arena.deinit();

    var modules: Modules = undefined;
    try modules.init(arena.allocator());

    var cli: Cli = undefined;
    try cli.init(arena.allocator(), &config);

    try Modules.print(&config, modules);
}
