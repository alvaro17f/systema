const std = @import("std");
const Colors = @import("utils").colors;

pub fn getColors(allocator: std.mem.Allocator) ![]const u8 {
    return std.fmt.allocPrint(allocator, "{s}  {s}  {s}  {s}  {s}  {s} {s}", .{
        Colors.BLUE,
        Colors.CYAN,
        Colors.GREEN,
        Colors.YELLOW,
        Colors.RED,
        Colors.MAGENTA,
        Colors.RESET,
    });
}
