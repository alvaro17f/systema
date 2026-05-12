const std = @import("std");
const Config = @import("root").Config;
const utils = @import("utils");
const fmt = utils.fmt;
const Colors = utils.colors;
const help_mod = @import("help.zig");
const version_mod = @import("version.zig");

const Self = @This();

allocator: std.mem.Allocator,
io: std.Io,
config: Config,

pub fn init(self: *Self, allocator: std.mem.Allocator, io: std.Io, config: *Config, args: std.process.Args) !void {
    self.* = .{
        .allocator = allocator,
        .io = io,
        .config = config.*,
    };

    var args_iter = std.process.Args.iterate(args);
    _ = args_iter.next(); // skip binary
    while (args_iter.next()) |arg| {
        var split = std.mem.splitScalar(u8, arg[2..], '=');
        const opt = split.first();
        const val = split.rest();

        switch (optKind(arg)) {
            .short => {
                const str = arg[1..];
                for (str) |b| {
                    switch (b) {
                        'h' => try help_mod.getHelp(self),
                        'v' => try version_mod.getVersion(self),
                        else => {
                            try fmt.stderr(self.io, "Invalid opt: '{c}'\n", .{b});
                            std.process.exit(1);
                        },
                    }
                }
            },
            .long => {
                if (eql(opt, "help")) {
                    try help_mod.getHelp(self);
                } else if (eql(opt, "version")) {
                    try version_mod.getVersion(self);
                } else if (eql(opt, "logo-path")) {
                    config.logo.path = val;
                } else if (eql(opt, "logo-color")) {
                    config.logo.color = Colors.hex(self.allocator, val) catch config.logo.color;
                } else if (eql(opt, "logo-gap")) {
                    config.logo.gap = std.fmt.parseInt(u8, val, 10) catch config.logo.gap;
                } else if (eql(opt, "icons-color")) {
                    config.icons.color = Colors.hex(self.allocator, val) catch config.icons.color;
                } else if (eql(opt, "labels-color")) {
                    config.labels.color = Colors.hex(self.allocator, val) catch config.labels.color;
                } else {
                    try fmt.stderr(self.io, "Invalid opt: '{s}'\n", .{opt});
                    std.process.exit(1);
                }
            },
            .positional => {},
        }
    }
}

fn optKind(a: []const u8) enum { short, long, positional } {
    if (std.mem.startsWith(u8, a, "--")) return .long;
    if (std.mem.startsWith(u8, a, "-")) return .short;
    return .positional;
}

fn parseArgBool(arg: []const u8) ?bool {
    if (arg.len == 0) return true;

    if (std.ascii.eqlIgnoreCase(arg, "true")) return true;
    if (std.ascii.eqlIgnoreCase(arg, "false")) return false;
    if (std.ascii.eqlIgnoreCase(arg, "1")) return true;
    if (std.ascii.eqlIgnoreCase(arg, "0")) return false;

    return null;
}

fn eql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

// -- Tests --

test "help message contains app name" {
    const msg = try std.fmt.allocPrint(std.testing.allocator, "Usage:\n  {s} [options]", .{"systema"});
    defer std.testing.allocator.free(msg);
    try std.testing.expect(std.mem.containsAtLeast(u8, msg, 1, "systema"));
}

test "version message contains version string" {
    const name = try std.ascii.allocUpperString(std.testing.allocator, "systema");
    defer std.testing.allocator.free(name);
    const msg = try std.fmt.allocPrint(std.testing.allocator, "{s} version: {s}", .{ name, "0.1.2" });
    defer std.testing.allocator.free(msg);
    try std.testing.expect(std.mem.containsAtLeast(u8, msg, 1, "0.1.2"));
}
