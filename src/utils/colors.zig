const std = @import("std");

pub fn hex(comptime hex_code: []const u8) []const u8 {
    const clean_hex = if (hex_code[0] == '#') hex_code[1..] else hex_code;

    if (clean_hex.len != 6) {
        @compileError("Hex color must be 6 characters long (RRGGBB)");
    }

    const r = std.fmt.parseInt(u8, clean_hex[0..2], 16) catch @compileError("Invalid Hex Red");
    const g = std.fmt.parseInt(u8, clean_hex[2..4], 16) catch @compileError("Invalid Hex Green");
    const b = std.fmt.parseInt(u8, clean_hex[4..6], 16) catch @compileError("Invalid Hex Blue");

    return std.fmt.comptimePrint("\x1b[38;2;{};{};{}m", .{ r, g, b });
}

pub const RED = hex("#FF0000");
pub const GREEN = hex("#00FF00");
pub const YELLOW = hex("#FFFF00");
pub const BLUE = hex("#0000FF");
pub const MAGENTA = hex("#FF00FF");
pub const CYAN = hex("#00FFFF");
pub const GRAY = hex("#808080");
pub const BLACK = hex("#000000");

pub const RESET = "\x1b[0m";
pub const BOLD = "\x1b[1m";
pub const UNDERLINE = "\x1b[4m";
