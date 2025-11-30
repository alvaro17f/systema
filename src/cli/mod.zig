const std = @import("std");
const Config = @import("root").Config;
const fmt = @import("utils").fmt;
const Colors = @import("utils").colors;

const Self = @This();

allocator: std.mem.Allocator,
config: Config,

const help = @import("help.zig").getHelp;
const version = @import("version.zig").getVersion;

pub fn init(self: *Self, allocator: std.mem.Allocator, config: *Config) !void {
    self.* = .{
        .allocator = allocator,
        .config = config.*,
    };

    var args = std.process.args();
    _ = args.next(); // skip binary
    while (args.next()) |arg| {
        var split = std.mem.splitScalar(u8, arg[2..], '=');
        const opt = split.first();
        const val = split.rest();

        switch (optKind(arg)) {
            .short => {
                const str = arg[1..];
                for (str) |b| {
                    switch (b) {
                        'h' => try help(self),
                        'v' => try version(self),
                        else => {
                            try fmt.stderr("Invalid opt: '{c}'\n", .{b});
                            std.process.exit(1);
                        },
                    }
                }
            },
            .long => {
                if (eql(opt, "help")) {
                    try help(self);
                } else if (eql(opt, "version")) {
                    try version(self);
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
                } else if (eql(opt, "info-offset")) {
                    config.info.offset = std.fmt.parseInt(u8, val, 10) catch config.info.offset;
                } else {
                    try fmt.stderr("Invalid opt: '{s}'\n", .{opt});
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
