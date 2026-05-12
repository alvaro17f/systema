const std = @import("std");
const zon = @import("build.zig.zon");

pub const version = std.SemanticVersion.parse(zon.version) catch @panic("Invalid version in build.zig.zon");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const utils_mod = b.createModule(.{
        .root_source_file = b.path("src/utils/mod.zig"),
        .target = target,
        .optimize = optimize,
    });

    const cli_mod = b.createModule(.{
        .root_source_file = b.path("src/cli/mod.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "utils", .module = utils_mod },
        },
    });

    const modules_mod = b.createModule(.{
        .root_source_file = b.path("src/modules/mod.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "utils", .module = utils_mod },
        },
    });

    const zon_mod = b.createModule(.{
        .root_source_file = b.path("build.zig.zon"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "systema",
        .version = version,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "cli", .module = cli_mod },
                .{ .name = "modules", .module = modules_mod },
                .{ .name = "utils", .module = utils_mod },
                .{ .name = "zon", .module = zon_mod },
            },
        }),
    });

    if (target.result.os.tag == .linux) {
        exe.root_module.link_libc = true;
    }

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const test_step = b.step("test", "Run tests");

    const zig_exe = b.graph.zig_exe;

    const test_utils = b.addSystemCommand(&.{ zig_exe, "test", "-Mroot=src/utils/mod.zig" });
    test_step.dependOn(&test_utils.step);

    const test_cli = b.addSystemCommand(&.{ zig_exe, "test", "--dep", "utils", "-Mroot=src/cli/mod.zig", "-Mutils=src/utils/mod.zig" });
    test_step.dependOn(&test_cli.step);

    const test_modules = b.addSystemCommand(&.{ zig_exe, "test", "--dep", "utils", "-Mroot=src/modules/mod.zig", "-Mutils=src/utils/mod.zig", "-lc" });
    test_step.dependOn(&test_modules.step);

    const test_main = b.addSystemCommand(&.{ zig_exe, "test", "--dep", "cli", "--dep", "modules", "--dep", "utils", "--dep", "zon", "-Mroot=src/main.zig", "-Mcli=src/cli/mod.zig", "-Mmodules=src/modules/mod.zig", "-Mutils=src/utils/mod.zig", "-Mzon=build.zig.zon", "-lc" });
    test_step.dependOn(&test_main.step);
}
