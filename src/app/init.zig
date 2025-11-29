const std = @import("std");
const root = @import("root");
const allocator = @import("utils").allocator.allocator;
const Modules = @import("modules.zig");

pub fn init(config: *const root.Config) !void {
    var modules = try Modules.init(allocator);
    defer modules.deinit();

    try Modules.print(config, modules);
}
