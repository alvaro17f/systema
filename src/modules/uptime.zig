const std = @import("std");

pub const Uptime = struct {
    days: i64,
    hours: i64,
    minutes: i64,
    seconds: i64,
};

pub fn parseUptimeSeconds(data: []const u8) i64 {
    var it = std.mem.tokenizeScalar(u8, data, ' ');
    const uptime_seconds_str = it.next() orelse return 0;
    const uptime_float = std.fmt.parseFloat(f64, uptime_seconds_str) catch return 0;
    return @as(i64, @intFromFloat(uptime_float));
}

fn getSystemUptimeInSeconds(io: std.Io) !i64 {
    const file = std.Io.Dir.openFileAbsolute(io, "/proc/uptime", .{}) catch return 0;
    defer file.close(io);

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(io, &file_buffer);
    const content = reader.interface.allocRemaining(std.heap.page_allocator, .limited(4096)) catch return 0;
    defer std.heap.page_allocator.free(content);

    return parseUptimeSeconds(content);
}

pub fn calcUptime(uptime_in_seconds: i64) Uptime {
    const days = @divTrunc(uptime_in_seconds, 86400);
    const hours = @divTrunc(uptime_in_seconds, 3600) - (days * 24);
    const minutes = @divTrunc(uptime_in_seconds, 60) - (days * 24 * 60) - (hours * 60);
    const seconds = @mod(uptime_in_seconds, 60);
    return .{ .days = days, .hours = hours, .minutes = minutes, .seconds = seconds };
}

pub fn getUptimeInfo(allocator: std.mem.Allocator, io: std.Io) ![]const u8 {
    const uptime_in_seconds = try getSystemUptimeInSeconds(io);
    const uptime = calcUptime(uptime_in_seconds);

    var parts: std.ArrayList([]const u8) = .empty;
    defer parts.deinit(allocator);

    if (uptime.days > 0) try parts.append(allocator, std.fmt.allocPrint(allocator, "{} days", .{uptime.days}) catch return "0 seconds");
    if (uptime.hours > 0) try parts.append(allocator, std.fmt.allocPrint(allocator, "{} hours", .{uptime.hours}) catch return "0 seconds");
    if (uptime.minutes > 0) try parts.append(allocator, std.fmt.allocPrint(allocator, "{} minutes", .{uptime.minutes}) catch return "0 seconds");
    if (uptime.seconds > 0) try parts.append(allocator, std.fmt.allocPrint(allocator, "{} seconds", .{uptime.seconds}) catch return "0 seconds");
    defer for (parts.items) |part| {
        allocator.free(part);
    };

    if (parts.items.len == 0) return "0 seconds";

    return std.mem.join(allocator, " ", parts.items);
}
