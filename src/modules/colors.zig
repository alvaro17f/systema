const std = @import("std");
const colors = @import("../utils/colors.zig");

pub fn getColors(allocator: std.mem.Allocator) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{s}  {s}  {s}  {s}  {s}  {s} {s}", .{
        colors.Blue,
        colors.Cyan,
        colors.Green,
        colors.Yellow,
        colors.Red,
        colors.Magenta,
        colors.Reset,
    });
}
