const std = @import("std");
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

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    var config = Config{
        .name = @tagName(zon.name),
        .version = zon.version,
    };

    log.debug("{s}***** DEBUG BUILD: {s}{s}{s}: {s}{s}{s} *****{s}", .{ Colors.RED, Colors.YELLOW, config.name, Colors.RESET, Colors.GREEN, config.version, Colors.RED, Colors.RESET });

    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();

    var modules: Modules = undefined;
    try modules.init(arena.allocator(), io, init.environ_map.*);

    var cli: Cli = undefined;
    try cli.init(arena.allocator(), io, &config, init.minimal.args);

    try Modules.print(io, init.environ_map.*, &config, modules);
}

test "sanity check: test runner works" {
    try std.testing.expect(true);
}
