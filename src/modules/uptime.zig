const std = @import("std");
const ArrayList = std.ArrayList;

const Uptime = struct {
    days: i64,
    hours: i64,
    minutes: i64,
    seconds: i64,
};

pub fn getSystemUptimeInSeconds() !i64 {
    const file = std.fs.openFileAbsolute("/proc/uptime", .{ .mode = .read_only }) catch return 0;
    defer file.close();

    const content = file.readToEndAlloc(std.heap.page_allocator, 4096) catch return 0;
    defer std.heap.page_allocator.free(content);

    var it = std.mem.tokenizeScalar(u8, content, ' ');
    const uptime_seconds_str = it.next() orelse return 0;
    const uptime_float = std.fmt.parseFloat(f64, uptime_seconds_str) catch return 0;

    return @as(i64, @intFromFloat(uptime_float));
}

pub fn getUptime(uptime: *Uptime) !void {
    const uptime_in_seconds = try getSystemUptimeInSeconds();

    uptime.* = .{
        .days = @divTrunc(uptime_in_seconds, 86400),
        .hours = @divTrunc(uptime_in_seconds, 3600) - (uptime.days * 24),
        .minutes = @divTrunc(uptime_in_seconds, 60) - (uptime.hours * 60),
        .seconds = @mod(uptime_in_seconds, 60),
    };
}

pub fn getUptimeInfo(allocator: std.mem.Allocator) ![]const u8 {
    var uptime = Uptime{ .days = 0, .hours = 0, .minutes = 0, .seconds = 0 };
    try getUptime(&uptime);

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
