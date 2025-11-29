const std = @import("std");
const Colors = @import("utils").colors;

pub fn getColors(allocator: std.mem.Allocator) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{s}  {s}  {s}  {s}  {s}  {s} {s}", .{
        Colors.Blue,
        Colors.Cyan,
        Colors.Green,
        Colors.Yellow,
        Colors.Red,
        Colors.Magenta,
        Colors.Reset,
    });
}
