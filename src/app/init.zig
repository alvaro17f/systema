const std = @import("std");
const root = @import("root");
const allocator = @import("allocator").allocator;
const Modules = @import("modules.zig");
const SystemInfo = @import("../utils/system.zig");

pub fn init(config: *const root.Config) !void {
    var modules = try Modules.init(allocator);
    defer modules.deinit();

    try Modules.print(config, modules);
}
