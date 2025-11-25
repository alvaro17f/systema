const std = @import("std");
const zon = @import("build.zig.zon");

pub const version = std.SemanticVersion.parse(zon.version) catch @panic("Invalid version in build.zig.zon");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.addModule("systema", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const allocator_mod = b.createModule(.{
        .root_source_file = b.path("src/utils/allocator.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zon_mod = b.createModule(.{
        .root_source_file = b.path("build.zig.zon"),
    });

    const exe = b.addExecutable(.{
        .name = "systema",
        .version = version,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "systema", .module = mod },
                .{ .name = "allocator", .module = allocator_mod },
                .{ .name = "zon", .module = zon_mod },
            },
        }),
    });

    if (target.result.os.tag == .linux) {
        exe.linkLibC();
    }

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // const mod_tests = b.addTest(.{
    //     .root_module = mod,
    // });

    // const run_mod_tests = b.addRunArtifact(mod_tests);
    //
    // const exe_tests = b.addTest(.{
    //     .root_module = exe.root_module,
    // });

    // const run_exe_tests = b.addRunArtifact(exe_tests);

    // const test_step = b.step("test", "Run tests");
    // test_step.dependOn(&run_mod_tests.step);
    // test_step.dependOn(&run_exe_tests.step);
}
