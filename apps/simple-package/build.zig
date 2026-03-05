const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const packModule = b.addModule("simple-package", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("common.zig"),
    });

    const tests = b.addTest(.{
        .root_module = packModule,
    });

    const runTests = b.addRunArtifact(tests);
    const testStep = b.step("test", "Run common tests");
    testStep.dependOn(&runTests.step);
}
