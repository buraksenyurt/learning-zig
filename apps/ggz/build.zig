const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "ggz",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();
    exe.linkSystemLibrary("SDL3");

    exe.addIncludePath(.{ .cwd_relative = "C:/SDL/SDL3-build/include" });
    exe.addLibraryPath(.{ .cwd_relative = "C:/SDL/SDL3-build/lib" });

    b.installArtifact(exe);

    const sdl_dll = b.addInstallFileWithDir(
        .{ .cwd_relative = "C:/SDL/SDL3-build/bin/SDL3.dll" },
        .bin,
        "SDL3.dll",
    );
    b.getInstallStep().dependOn(&sdl_dll.step);

    const runCmd = b.addRunArtifact(exe);
    runCmd.step.dependOn(b.getInstallStep());

    const runStep = b.step("run", "Run the ggz executable");
    runStep.dependOn(&runCmd.step);
}
