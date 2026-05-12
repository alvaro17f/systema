const std = @import("std");
const Colors = @import("utils").colors;

const Memory = struct {
    total: f64,
    available: f64,
    used: f64,
    used_percent: f64,
};

fn parseMeminfo(io: std.Io, memory: *Memory) !void {
    const file = try std.Io.Dir.openFileAbsolute(io, "/proc/meminfo", .{});
    defer file.close(io);

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(io, &file_buffer);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (std.mem.startsWith(u8, line, "MemTotal:")) {
            var value_it = std.mem.tokenizeScalar(u8, line, ':');
            _ = value_it.next();
            const value = value_it.next() orelse continue;
            const trimmed_value = std.mem.trim(u8, value, "kB \t");
            const total_kb = std.fmt.parseFloat(f64, trimmed_value) catch continue;
            memory.total = total_kb / 1024.0 / 1024.0;
        } else if (std.mem.startsWith(u8, line, "MemAvailable:")) {
            var value_it = std.mem.tokenizeScalar(u8, line, ':');
            _ = value_it.next();
            const value = value_it.next() orelse continue;
            const trimmed_value = std.mem.trim(u8, value, "kB \t");
            const available_kb = std.fmt.parseFloat(f64, trimmed_value) catch continue;
            memory.available = available_kb / 1024.0 / 1024.0;
        }
    }

    memory.used = memory.total - memory.available;
    memory.used_percent = if (memory.total > 0) (memory.used / memory.total) * 100 else 0;
}

pub fn getMemoryInfo(allocator: std.mem.Allocator, io: std.Io) ![]const u8 {
    var meminfo = Memory{
        .total = 0,
        .available = 0,
        .used = 0,
        .used_percent = 0,
    };

    try parseMeminfo(io, &meminfo);

    return std.fmt.allocPrint(
        allocator,
        "{d:.2} GiB / {d:.2} GiB ({s}{d:.0}%{s})",
        .{ meminfo.used, meminfo.total, Colors.CYAN, meminfo.used_percent, Colors.RESET },
    ) catch |err| return err;
}

// Tests with pure parsing using Reader instead of file
pub const TestMemory = struct {
    total: f64,
    available: f64,
    used: f64,
    used_percent: f64,
};

pub fn parseMeminfoData(data: []const u8) TestMemory {
    var memory = TestMemory{ .total = 0, .available = 0, .used = 0, .used_percent = 0 };
    var line_iter = std.mem.splitScalar(u8, data, '\n');
    while (line_iter.next()) |line| {
        if (std.mem.startsWith(u8, line, "MemTotal:")) {
            var value_it = std.mem.tokenizeScalar(u8, line, ':');
            _ = value_it.next();
            const value = value_it.next() orelse continue;
            const trimmed_value = std.mem.trim(u8, value, "kB \t");
            const total_kb = std.fmt.parseFloat(f64, trimmed_value) catch continue;
            memory.total = total_kb / 1024.0 / 1024.0;
        } else if (std.mem.startsWith(u8, line, "MemAvailable:")) {
            var value_it = std.mem.tokenizeScalar(u8, line, ':');
            _ = value_it.next();
            const value = value_it.next() orelse continue;
            const trimmed_value = std.mem.trim(u8, value, "kB \t");
            const available_kb = std.fmt.parseFloat(f64, trimmed_value) catch continue;
            memory.available = available_kb / 1024.0 / 1024.0;
        }
    }
    memory.used = memory.total - memory.available;
    memory.used_percent = if (memory.total > 0) (memory.used / memory.total) * 100 else 0;
    return memory;
}
