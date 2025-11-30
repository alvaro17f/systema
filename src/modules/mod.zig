const std = @import("std");
const root = @import("root");
const fmt = @import("utils").fmt;
const Colors = @import("utils").colors;

pub const Self = @This();

var hostname_buf: [std.posix.HOST_NAME_MAX]u8 = undefined;

allocator: std.mem.Allocator,
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

pub fn init(allocator: std.mem.Allocator) !Self {
    const username = @import("username.zig").getUsername();

    const hostname = @import("hostname.zig").getHostname(&hostname_buf);

    const system = @import("system.zig").getSystemInfo(allocator);
    errdefer allocator.free(system);

    const kernel = @import("kernel.zig").getKernelInfo(allocator);
    errdefer allocator.free(kernel);

    const cpu = @import("cpu.zig").getCpuInfo(allocator);
    errdefer allocator.free(cpu);

    const shell = try @import("shell.zig").getShell(allocator);
    errdefer allocator.free(shell);

    const memory = try @import("memory.zig").getMemoryInfo(allocator);
    errdefer allocator.free(memory);

    const desktop = try @import("desktop.zig").getDesktop(allocator);
    errdefer allocator.free(desktop);

    const uptime = try @import("uptime.zig").getUptimeInfo(allocator);
    errdefer allocator.free(uptime);

    const storage = try @import("storage.zig").getStorage(allocator, "/");
    errdefer allocator.free(storage);

    const colors = try @import("colors.zig").getColors(allocator);
    errdefer allocator.free(colors);

    return .{
        .allocator = allocator,
        .username = username,
        .hostname = hostname,
        .system = system,
        .kernel = kernel,
        .cpu = cpu,
        .shell = shell,
        .memory = memory,
        .desktop = desktop,
        .uptime = uptime,
        .storage = storage,
        .colors = colors,
    };
}

pub fn deinit(self: *Self) void {
    self.allocator.free(self.system);
    self.allocator.free(self.kernel);
    self.allocator.free(self.cpu);
    self.allocator.free(self.shell);
    self.allocator.free(self.memory);
    self.allocator.free(self.desktop);
    self.allocator.free(self.uptime);
    self.allocator.free(self.storage);
    self.allocator.free(self.colors);
}

pub fn print(config: *const root.Config, modules: Self) !void {
    var info_lines: std.ArrayList([]const u8) = .empty;
    defer info_lines.deinit(modules.allocator);
    defer for (info_lines.items) |line| modules.allocator.free(line);

    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}{s}{s}@{s}{s}{s} ~", .{
        Colors.YELLOW, modules.username, Colors.RED, Colors.GREEN, modules.hostname, Colors.RESET,
    }));

    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}System{s}         {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.system }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Kernel{s}         {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.kernel }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Desktop{s}        {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.desktop }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}CPU{s}            {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.cpu }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Shell{s}          {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.shell }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Uptime{s}         {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.uptime }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Memory{s}         {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.memory }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}󱥎  {s}Storage (/){s}    {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.storage }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s}  {s}Colors{s}         {s}", .{ config.icons.color, config.info.color, Colors.RESET, modules.colors }));
    try info_lines.append(modules.allocator, try std.fmt.allocPrint(modules.allocator, "{s} version   {s}", .{ config.name, config.version }));

    try fmt.print("\n", .{});

    if (config.logo.enabled) {
        var logo_list: std.ArrayList([]const u8) = .empty;
        defer logo_list.deinit(modules.allocator);

        var file_content: ?[]u8 = null;
        defer if (file_content) |c| modules.allocator.free(c);

        var logo_content = config.logo.embed;
        if (config.logo.path) |p| {
            if (std.fs.cwd().openFile(p, .{})) |file| {
                defer file.close();
                if (file.readToEndAlloc(modules.allocator, std.math.maxInt(usize))) |content| {
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
                try fmt.print("{s}{s}{s}", .{ config.logo.color, logo[i], Colors.RESET });
                const width = std.unicode.utf8CountCodepoints(logo[i]) catch logo[i].len;
                const padding = logo_width - width + gap;
                for (0..padding) |_| try fmt.print(" ", .{});
            } else {
                const padding = logo_width + gap;
                for (0..padding) |_| try fmt.print(" ", .{});
            }

            if (i < info_lines.items.len) {
                try fmt.print("{s}", .{info_lines.items[i]});
            }
            try fmt.print("\n", .{});
        }
    } else {
        for (info_lines.items) |line| {
            try fmt.print("{s}\n", .{line});
        }
    }

    try fmt.print("\n", .{});
}
