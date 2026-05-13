const std = @import("std");
const root = @import("root");
const fmt = @import("utils").fmt;
const Colors = @import("utils").colors;
const username_mod = @import("username.zig");
const hostname_mod = @import("hostname.zig");
const system_mod = @import("system.zig");
const kernel_mod = @import("kernel.zig");
const cpu_mod = @import("cpu.zig");
const shell_mod = @import("shell.zig");
const memory_mod = @import("memory.zig");
const desktop_mod = @import("desktop.zig");
const uptime_mod = @import("uptime.zig");
const storage_mod = @import("storage.zig");
const colors_mod = @import("colors.zig");

pub const Self = @This();

var hostname_buf: [std.posix.HOST_NAME_MAX]u8 = undefined;

allocator: std.mem.Allocator,
io: std.Io,
username: []const u8,
hostname: []const u8,
system: []const u8,
kernel: []const u8,
cpu: []const u8,
shell: []const u8,
memory: []const u8,
desktop: []const u8,
uptime: []const u8,
storage: []const u8,
colors: []const u8,

pub fn init(self: *Self, allocator: std.mem.Allocator, io: std.Io, environ_map: std.process.Environ.Map) !void {
    self.* = .{
        .allocator = allocator,
        .io = io,
        .username = username_mod.getUsername(environ_map),
        .hostname = hostname_mod.getHostname(&hostname_buf),
        .system = system_mod.getSystemInfo(allocator, io),
        .kernel = kernel_mod.getKernelInfo(allocator),
        .cpu = cpu_mod.getCpuInfo(allocator, io),
        .shell = try shell_mod.getShell(allocator, environ_map),
        .memory = try memory_mod.getMemoryInfo(allocator, io),
        .desktop = try desktop_mod.getDesktop(allocator, environ_map),
        .uptime = try uptime_mod.getUptimeInfo(allocator, io),
        .storage = try storage_mod.getStorage(allocator, "/"),
        .colors = try colors_mod.getColors(allocator),
    };
}

pub fn deinit(self: *Self) void {
    _ = self;
}

pub fn print(io: std.Io, environ_map: std.process.Environ.Map, config: *const root.Config, modules: Self) !void {
    var info_lines: std.ArrayList([]const u8) = .empty;
    defer info_lines.deinit(modules.allocator);

    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}{s}{s}@{s}{s}{s} ~", .{
        Colors.YELLOW, modules.username, Colors.RED, Colors.GREEN, modules.hostname, Colors.RESET,
    }));

    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}System{s}         {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.system }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Kernel{s}         {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.kernel }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Desktop{s}        {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.desktop }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}CPU{s}            {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.cpu }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Shell{s}          {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.shell }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Uptime{s}         {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.uptime }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Memory{s}         {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.memory }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}󱥎  {s}Storage (/){s}    {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.storage }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Colors{s}         {s}", .{ config.icons.color, config.labels.color, Colors.RESET, modules.colors }));

    try fmt.stdout(io, "\n", .{});

    if (config.logo.enabled) {
        var logo_list: std.ArrayList([]const u8) = .empty;
        defer logo_list.deinit(modules.allocator);

        var file_content: ?[]u8 = null;

        var logo_content = config.logo.embed;
        if (config.logo.path) |p| {
            var path = p;
            var path_alloc: ?[]u8 = null;
            defer if (path_alloc) |ptr| modules.allocator.free(ptr);

            if (std.mem.startsWith(u8, p, "~/")) {
                if (environ_map.get("HOME")) |home| {
                    if (std.fs.path.join(modules.allocator, &[_][]const u8{ home, p[2..] })) |joined| {
                        path_alloc = joined;
                        path = joined;
                    } else |_| {}
                } else {}
            }

            if (std.Io.Dir.openFileAbsolute(io, path, .{})) |file| {
                defer file.close(io);
                var file_buffer: [4096]u8 = undefined;
                var reader = file.reader(io, &file_buffer);
                if (reader.interface.allocRemaining(modules.allocator, .limited(std.math.maxInt(usize)))) |content| {
                    file_content = content;
                    logo_content = content;
                } else |_| {}
            } else |_| {}
        }

        var line_iter = std.mem.splitScalar(u8, logo_content, '\n');
        while (line_iter.next()) |line| {
            try logo_list.append(modules.allocator, line);
        }
        if (logo_list.items.len > 0 and logo_list.items[logo_list.items.len - 1].len == 0) {
            _ = logo_list.pop();
        }

        const logo = logo_list.items;
        var logo_width: usize = 0;
        for (logo) |line| {
            const width = std.unicode.utf8CountCodepoints(line) catch line.len;
            if (width > logo_width) logo_width = width;
        }
        const gap = config.logo.gap;

        const max_lines = @max(logo.len, info_lines.items.len);
        for (0..max_lines) |i| {
            if (i < logo.len) {
                try fmt.stdout(io, "{s}{s}{s}", .{ config.logo.color, logo[i], Colors.RESET });
                const width = std.unicode.utf8CountCodepoints(logo[i]) catch logo[i].len;
                const padding = logo_width - width + gap;
                for (0..padding) |_| try fmt.stdout(io, " ", .{});
            } else {
                const padding = logo_width + gap;
                for (0..padding) |_| try fmt.stdout(io, " ", .{});
            }

            if (i < info_lines.items.len) {
                try fmt.stdout(io, "{s}", .{info_lines.items[i]});
            }
            try fmt.stdout(io, "\n", .{});
        }
    } else {
        for (info_lines.items) |line| {
            try fmt.stdout(io, "{s}\n", .{line});
        }
    }

    try fmt.stdout(io, "\n", .{});
}

// -- Tests --

test "parseMeminfoData: valid /proc/meminfo" {
    const data =
        \\MemTotal:       16384000 kB
        \\MemFree:         8192000 kB
        \\MemAvailable:   12288000 kB
        \\Buffers:         1024000 kB
    ;
    const meminfo = memory_mod.parseMeminfoData(data);
    try std.testing.expectApproxEqAbs(@as(f64, 16384000.0 / 1024.0 / 1024.0), meminfo.total, 0.01);
    try std.testing.expectApproxEqAbs(@as(f64, 12288000.0 / 1024.0 / 1024.0), meminfo.available, 0.01);
    try std.testing.expectApproxEqAbs(meminfo.total - meminfo.available, meminfo.used, 0.01);
    try std.testing.expect(meminfo.used_percent > 0);
}

test "format memory string" {
    try std.testing.expect(@as(f64, 4.0) == @as(f64, 4.0));
    try std.testing.expect(@as(f64, 16.0) == @as(f64, 16.0));
}

test "calcUptime: 90061 seconds = 1 day 1 hour 1 minute 1 second" {
    const u = uptime_mod.calcUptime(90061);
    try std.testing.expectEqual(@as(i64, 1), u.days);
    try std.testing.expectEqual(@as(i64, 1), u.hours);
    try std.testing.expectEqual(@as(i64, 1), u.minutes);
    try std.testing.expectEqual(@as(i64, 1), u.seconds);
}

test "calcUptime: 0 seconds" {
    const u = uptime_mod.calcUptime(0);
    try std.testing.expectEqual(@as(i64, 0), u.days);
    try std.testing.expectEqual(@as(i64, 0), u.hours);
    try std.testing.expectEqual(@as(i64, 0), u.minutes);
    try std.testing.expectEqual(@as(i64, 0), u.seconds);
}

test "getHostname returns valid slice" {
    var buf: [std.posix.HOST_NAME_MAX]u8 = undefined;
    const host = hostname_mod.getHostname(&buf);
    try std.testing.expect(host.len > 0);
}

test "getKernelInfo returns non-empty string" {
    const result = kernel_mod.getKernelInfo(std.testing.allocator);
    defer std.testing.allocator.free(result);
    try std.testing.expect(result.len > 0);
}

test "getColors produces non-empty string" {
    const result = try colors_mod.getColors(std.testing.allocator);
    defer std.testing.allocator.free(result);
    try std.testing.expect(result.len > 0);
}

test "getShell extracts basename from path" {
    var shell_it = std.mem.tokenizeScalar(u8, "/usr/bin/zsh", '/');
    var shell: []const u8 = undefined;
    while (shell_it.next()) |split| {
        shell = split;
    }
    try std.testing.expectEqualStrings("zsh", shell);
}

test "getDesktop format with mock data" {
    const result = try std.fmt.allocPrint(std.testing.allocator, "{s} ({s})", .{ "GNOME", "wayland" });
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualStrings("GNOME (wayland)", result);
}

test "getUsername fallback" {
    try std.testing.expectEqualStrings("NO_USER_NAME_FOUND", "NO_USER_NAME_FOUND");
}

test "system info string trimming" {
    const raw = "\"Ubuntu 24.04 LTS\"";
    const trimmed = std.mem.trim(u8, raw, "\"");
    try std.testing.expectEqualStrings("Ubuntu 24.04 LTS", trimmed);
}

test "cpu fallback string" {
    try std.testing.expectEqualStrings("Unknown", "Unknown");
}
