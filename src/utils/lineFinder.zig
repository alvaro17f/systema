const std = @import("std");

pub fn lineFinder(allocator: std.mem.Allocator, file_path: []const u8, starts_with: []const u8, from_character: u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_only });
    defer file.close();

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(&file_buffer);
    var line_number: usize = 0;

    while (try reader.interface.takeDelimiter('\n')) |line| {
        line_number += 1;
        if (std.mem.startsWith(u8, line, starts_with)) {
            var name_it = std.mem.tokenizeScalar(u8, line, from_character);
            _ = name_it.next();
            const name = name_it.next() orelse return error.LineIsNull;

            return try allocator.dupe(u8, std.mem.trim(u8, name, " \t"));
        }
    }

    return error.LineNotFound;
}
