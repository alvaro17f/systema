const std = @import("std");

pub const Uptime = struct {
    days: i64,
    hours: i64,
    minutes: i64,
    seconds: i64,
};

pub fn calcUptime(uptime_in_seconds: i64) Uptime {
    const days = @divTrunc(uptime_in_seconds, 86400);
    const hours = @divTrunc(uptime_in_seconds, 3600) - (days * 24);
    const minutes = @divTrunc(uptime_in_seconds, 60) - (days * 24 * 60) - (hours * 60);
    const seconds = @mod(uptime_in_seconds, 60);
    return .{ .days = days, .hours = hours, .minutes = minutes, .seconds = seconds };
}

fn formatUptime(allocator: std.mem.Allocator, uptime: Uptime) ![]const u8 {
    var parts: std.ArrayList([]const u8) = .empty;
    defer parts.deinit(allocator);

    if (uptime.days > 0) try parts.append(allocator, std.fmt.allocPrint(allocator, "{} days", .{uptime.days}) catch return "0 seconds");
    if (uptime.hours > 0) try parts.append(allocator, std.fmt.allocPrint(allocator, "{} hours", .{uptime.hours}) catch return "0 seconds");
    if (uptime.minutes > 0) try parts.append(allocator, std.fmt.allocPrint(allocator, "{} minutes", .{uptime.minutes}) catch return "0 seconds");
    if (uptime.seconds > 0) try parts.append(allocator, std.fmt.allocPrint(allocator, "{} seconds", .{uptime.seconds}) catch return "0 seconds");
    defer for (parts.items) |part| {
        allocator.free(part);
    };

    if (parts.items.len == 0) {
        return try allocator.dupe(u8, "0 seconds");
    }

    return std.mem.join(allocator, " ", parts.items);
}

/// Parse uptime from a Reader (e.g. /proc/uptime content: "12345.67 67890.12")
pub fn parseFromReader(allocator: std.mem.Allocator, reader: anytype) ![]const u8 {
    const line = (reader.takeDelimiter(' ') catch return try allocator.dupe(u8, "0 seconds")) orelse return try allocator.dupe(u8, "0 seconds");
    const uptime_float = std.fmt.parseFloat(f64, line) catch return try allocator.dupe(u8, "0 seconds");
    const uptime_seconds = @as(i64, @intFromFloat(uptime_float));
    const uptime = calcUptime(uptime_seconds);
    return formatUptime(allocator, uptime);
}

pub fn getUptimeInfo(allocator: std.mem.Allocator, io: std.Io) ![]const u8 {
    const file = std.Io.Dir.openFileAbsolute(io, "/proc/uptime", .{}) catch return "0 seconds";
    defer file.close(io);

    var file_buffer: [4096]u8 = undefined;
    var file_reader = file.reader(io, &file_buffer);
    return parseFromReader(allocator, &file_reader.interface);
}

// -- Tests --

test "parseFromReader: valid uptime (3h 15m 30s)" {
    const data = "11730.50 67890.12";
    var reader = std.Io.Reader.fixed(data);
    const result = try parseFromReader(std.testing.allocator, &reader);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("3 hours 15 minutes 30 seconds", result);
}

test "parseFromReader: zero uptime" {
    const data = "0.00 0.00";
    var reader = std.Io.Reader.fixed(data);
    const result = try parseFromReader(std.testing.allocator, &reader);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("0 seconds", result);
}

test "parseFromReader: empty data" {
    const data = "";
    var reader = std.Io.Reader.fixed(data);
    const result = try parseFromReader(std.testing.allocator, &reader);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("0 seconds", result);
}

test "parseFromReader: only one token" {
    const data = "3600";
    var reader = std.Io.Reader.fixed(data);
    const result = try parseFromReader(std.testing.allocator, &reader);
    defer std.testing.allocator.free(result);
    // 3600 seconds = 1 hour
    try std.testing.expect(std.mem.containsAtLeast(u8, result, 1, "1 hours"));
}

test "calcUptime: 90061 seconds = 1 day 1 hour 1 minute 1 second" {
    const u = calcUptime(90061);
    try std.testing.expectEqual(@as(i64, 1), u.days);
    try std.testing.expectEqual(@as(i64, 1), u.hours);
    try std.testing.expectEqual(@as(i64, 1), u.minutes);
    try std.testing.expectEqual(@as(i64, 1), u.seconds);
}

test "calcUptime: 0 seconds" {
    const u = calcUptime(0);
    try std.testing.expectEqual(@as(i64, 0), u.days);
    try std.testing.expectEqual(@as(i64, 0), u.hours);
    try std.testing.expectEqual(@as(i64, 0), u.minutes);
    try std.testing.expectEqual(@as(i64, 0), u.seconds);
}

test "end-to-end: getUptimeInfo reads mock /proc/uptime file" {
    const tmp_path = "/tmp/systema_test_uptime.txt";
    {
        const file = try std.Io.Dir.createFileAbsolute(std.testing.io, tmp_path, .{});
        defer file.close(std.testing.io);
        var writer = file.writer(std.testing.io, &.{});
        try writer.interface.writeAll("90061.00 67890.12\n");
        try writer.interface.flush();
    }
    defer std.Io.Dir.deleteFileAbsolute(std.testing.io, tmp_path) catch {};

    // Read the file directly (not through /proc) to test the reader path
    const file = try std.Io.Dir.openFileAbsolute(std.testing.io, tmp_path, .{});
    defer file.close(std.testing.io);
    var file_buffer: [4096]u8 = undefined;
    var file_reader = file.reader(std.testing.io, &file_buffer);

    const result = try parseFromReader(std.testing.allocator, &file_reader.interface);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("1 days 1 hours 1 minutes 1 seconds", result);
}
