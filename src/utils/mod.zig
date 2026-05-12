const std = @import("std");

pub const colors = @import("./colors.zig");
pub const fmt = @import("./fmt.zig");
pub const lineFinder = @import("./lineFinder.zig");

// -- Tests consolidated here (Zig 0.16 only discovers tests from root module) --

test "hex: valid 6-char hex with allocator" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const result = try colors.hex(arena.allocator(), "AABBCC");
    try std.testing.expect(std.mem.eql(u8, result, "\x1b[38;2;170;187;204m"));
}

test "hex: valid hex with # prefix" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const result = try colors.hex(arena.allocator(), "#AABBCC");
    try std.testing.expect(std.mem.eql(u8, result, "\x1b[38;2;170;187;204m"));
}

test "hex: invalid length returns error" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    try std.testing.expectError(error.InvalidLength, colors.hex(arena.allocator(), "ABC"));
}

test "hex: invalid chars returns error" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    try std.testing.expectError(error.InvalidCharacter, colors.hex(arena.allocator(), "GGGGGG"));
}

test "comptime colors exist and are non-empty" {
    try std.testing.expect(colors.RED.len > 0);
    try std.testing.expect(colors.GREEN.len > 0);
    try std.testing.expect(colors.BLUE.len > 0);
    try std.testing.expect(colors.CYAN.len > 0);
    try std.testing.expect(colors.RESET.len > 0);
}

test "lineFinder finds line in mock file" {
    const tmp_path = "/tmp/systema_test_linefinder.txt";
    {
        const file = try std.Io.Dir.createFileAbsolute(std.testing.io, tmp_path, .{});
        defer file.close(std.testing.io);
        var writer = file.writer(std.testing.io, &.{});
        try writer.interface.writeAll("PRETTY_NAME=\"TestOS 1.0\"\n");
        try writer.interface.writeAll("ID=testos\n");
        try writer.interface.flush();
    }
    defer std.Io.Dir.deleteFileAbsolute(std.testing.io, tmp_path) catch {};

    const result = try lineFinder.lineFinder(std.testing.allocator, std.testing.io, tmp_path, "PRETTY_NAME", '=');
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("\"TestOS 1.0\"", result);
}

test "lineFinder returns error for missing line" {
    const tmp_path = "/tmp/systema_test_linefinder_missing.txt";
    {
        const file = try std.Io.Dir.createFileAbsolute(std.testing.io, tmp_path, .{});
        defer file.close(std.testing.io);
        var writer = file.writer(std.testing.io, &.{});
        try writer.interface.writeAll("SOME=thing\n");
        try writer.interface.flush();
    }
    defer std.Io.Dir.deleteFileAbsolute(std.testing.io, tmp_path) catch {};

    try std.testing.expectError(error.LineNotFound, lineFinder.lineFinder(std.testing.allocator, std.testing.io, tmp_path, "MISSING", '='));
}
