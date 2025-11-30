const std = @import("std");
const Cli = @import("mod.zig");
const Colors = @import("utils").colors;
const fmt = @import("utils").fmt;

pub fn getVersion(self: *Cli) !void {
    const name = try std.ascii.allocUpperString(self.allocator, self.config.name);

    const help = try std.fmt.allocPrint(self.allocator,
        \\
        \\  {s}{s} version{s}: {s}{s}{s}
        \\
    , .{ Colors.YELLOW, name, Colors.RESET, Colors.GREEN, self.config.version, Colors.RESET });

    try fmt.print("{s}\n", .{help});

    std.process.exit(0);
}
