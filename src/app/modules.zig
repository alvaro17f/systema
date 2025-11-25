const std = @import("std");
const root = @import("root");
const systema = @import("systema");
const style = @import("../utils/colors.zig");

const m_username = @import("../modules/username.zig");
const m_hostname = @import("../modules/hostname.zig");
const m_system = @import("../modules/system.zig");
const m_kernel = @import("../modules/kernel.zig");
const m_cpu = @import("../modules/cpu.zig");
const m_shell = @import("../modules/shell.zig");
const m_memory = @import("../modules/memory.zig");
const m_desktop = @import("../modules/desktop.zig");
const m_uptime = @import("../modules/uptime.zig");
const m_storage = @import("../modules/storage.zig");
const m_colors = @import("../modules/colors.zig");

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
    const username = m_username.getUsername();
    const hostname = m_hostname.getHostname(&hostname_buf);

    const system = m_system.getSystemInfo(allocator);
    errdefer allocator.free(system);

    const kernel = m_kernel.getKernelInfo(allocator);
    errdefer allocator.free(kernel);

    const cpu = m_cpu.getCpuInfo(allocator);
    errdefer allocator.free(cpu);

    const shell = try m_shell.getShell(allocator);
    errdefer allocator.free(shell);

    const memory = try m_memory.getMemoryInfo(allocator);
    errdefer allocator.free(memory);

    const desktop = try m_desktop.getDesktop(allocator);
    errdefer allocator.free(desktop);

    const uptime = try m_uptime.getUptimeInfo(allocator);
    errdefer allocator.free(uptime);

    const storage = try m_storage.getStorage(allocator, "/");
    errdefer allocator.free(storage);

    const colors = try m_colors.getColors(allocator);
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
    try systema.print(
        \\
        \\ {s}{s}{s}@{s}{s}{s} ~
        \\   System         {s}
        \\   Kernel         {s}
        \\   Desktop        {s}
        \\   CPU            {s}
        \\   Shell          {s}
        \\   Uptime         {s}
        \\   Memory         {s}
        \\ 󱥎  Storage (/)    {s}
        \\   Colors         {s}
        \\ {s} version   {s}
        \\
    , .{
        style.Yellow,
        modules.username,
        style.Red,
        style.Green,
        modules.hostname,
        style.Reset,
        modules.system,
        modules.kernel,
        modules.desktop,
        modules.cpu,
        modules.shell,
        modules.uptime,
        modules.memory,
        modules.storage,
        modules.colors,
        config.name,
        config.version,
    });
}
