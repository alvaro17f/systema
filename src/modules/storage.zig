const std = @import("std");
const c_statvfs = @cImport(@cInclude("sys/statvfs.h"));
const Colors = @import("utils").colors;

pub const DiskInfo = struct {
    disk_path: []const u8,
    disk_size: f64,
    disk_usage: f64,
    disk_usage_percentage: u8,
};

const GB = 1024 * 1024 * 1024;

pub fn getStorage(allocator: std.mem.Allocator, disk_path: []const u8) ![]const u8 {
    var stat: c_statvfs.struct_statvfs = undefined;
    if (c_statvfs.statvfs(disk_path.ptr, &stat) != 0) {
        return error.StatvfsFailed;
    }

    const block_size = stat.f_bsize;
    const total_blocks = stat.f_blocks;
    const available_blocks = stat.f_bavail;
    const total_size = total_blocks * block_size;
    const used_size = total_size - (available_blocks * block_size);
    const used_size_percentage = (used_size * 100) / total_size;

    const disk_info = DiskInfo{
        .disk_path = disk_path,
        .disk_size = @as(f64, @floatFromInt(total_size)) / GB,
        .disk_usage = @as(f64, @floatFromInt(used_size)) / GB,
        .disk_usage_percentage = @as(u8, @intCast(used_size_percentage)),
    };

    return std.fmt.allocPrint(allocator, "{d:.2} GiB / {d:.2} GiB ({s}{d}%{s})", .{
        disk_info.disk_usage,
        disk_info.disk_size,
        Colors.CYAN,
        disk_info.disk_usage_percentage,
        Colors.RESET,
    });
}
