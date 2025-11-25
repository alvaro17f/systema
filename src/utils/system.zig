const std = @import("std");
const root = @import("root");
const Modules = @import("../app/modules.zig");
const systema = @import("systema");

pub fn print(config: *const root.Config, modules: Modules.Self) !void {
    try systema.print("Modules:\n", .{});
    try systema.print("  username: {s}\n", .{modules.username});
    try systema.print("  hostname: {s}\n", .{modules.hostname});
    try systema.print("  system: {s}\n", .{modules.system});
    try systema.print("  kernel: {s}\n", .{modules.kernel});
    try systema.print("  cpu: {s}\n", .{modules.cpu});
    try systema.print("  shell: {s}\n", .{modules.shell});
    try systema.print("  memory: {s}\n", .{modules.memory});
    try systema.print("  desktop: {s}\n", .{modules.desktop});
    try systema.print("  uptime: {s}\n", .{modules.uptime});
    try systema.print("  storage: {s}\n", .{modules.storage});
    try systema.print("  colors: {s}\n", .{modules.colors});
    try systema.print("\n", .{});
    try systema.print("{s}: {s}\n", .{
        config.name,
        config.version,
    });
}
