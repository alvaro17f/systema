const std = @import("std");
const colors = @import("../utils/colors.zig");

const Memory = struct {
    total: f64,
    available: f64,
    used: f64,
    used_percent: f64,
};

fn getMeminfo(memory: *Memory) !void {
    const file = try std.fs.cwd().openFile("/proc/meminfo", .{ .mode = .read_only });
    defer file.close();

    var file_buffer: [4096]u8 = undefined;
    var reader = file.reader(&file_buffer);

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

pub fn getMemoryInfo(allocator: std.mem.Allocator) ![]const u8 {
    var meminfo = Memory{
        .total = 0,
        .available = 0,
        .used = 0,
        .used_percent = 0,
    };

    try getMeminfo(&meminfo);

    return std.fmt.allocPrint(
        allocator,
        "{d:.2} GiB / {d:.2} GiB ({s}{d:.0}%{s})",
        .{ meminfo.used, meminfo.total, colors.Cyan, meminfo.used_percent, colors.Reset },
    ) catch |err| return err;
}
