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
        \\ --logo-color=<color>                  Color of the logo
        \\ --logo-gap=<number>                   Gap between the logo and the info
        \\
        \\ --icons-color=<color>                 Color of the icons
        \\
        \\ --labels-color=<color>                Color of the labels
        \\
        \\ --info-offset=<number>                Offset of the info section from the top
        \\
    , .{self.config.name});

    try fmt.print("{s}\n", .{help});

    std.process.exit(0);
}
