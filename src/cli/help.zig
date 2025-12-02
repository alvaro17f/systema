const std = @import("std");
const fmt = @import("utils").fmt;
const Cli = @import("mod.zig");

pub fn getHelp(self: *Cli) !void {
    const help = try std.fmt.allocPrint(self.allocator,
        \\
        \\Usage:
        \\  {s} [options] [path...]
        \\
        \\  -h, --help                           Print this message and exit
        \\  -v, --version                        Print the version string
        \\
        \\ --logo-path=<path>                    Path to the logo file
        \\ --logo-gap=<number>                   Gap between the logo and the info
        \\ --logo-color=<color>                  Color of the logo
        \\ --icons-color=<color>                 Color of the icons
        \\ --labels-color=<color>                Color of the labels
        \\
    , .{self.config.name});

    try fmt.stdout("{s}\n", .{help});

    std.process.exit(0);
}
