const std = @import("std");
const Colors = @import("utils").colors;

pub const DiskInfo = struct {
    disk_path: []const u8,
    disk_size: f64,
    disk_usage: f64,
    disk_usage_percentage: u8,
};

const GB = 1024 * 1024 * 1024;

const struct_statvfs = extern struct {
    f_bsize: c_ulong,
    f_frsize: c_ulong,
    f_blocks: c_ulong,
    f_bfree: c_ulong,
    f_bavail: c_ulong,
    f_files: c_ulong,
    f_ffree: c_ulong,
    f_favail: c_ulong,
    f_fsid: c_ulong,
    f_flag: c_ulong,
    f_namemax: c_ulong,
    __reserved: [6]c_int,
};

extern "c" fn statvfs(path: [*:0]const u8, buf: *struct_statvfs) c_int;

pub fn getStorage(allocator: std.mem.Allocator, disk_path: []const u8) ![]const u8 {
    var stat: struct_statvfs = undefined;

    const path_z = try allocator.dupeZ(u8, disk_path);
    defer allocator.free(path_z);

    if (statvfs(path_z, &stat) != 0) {
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
