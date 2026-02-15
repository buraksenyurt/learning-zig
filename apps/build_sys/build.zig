const std = @import("std");

pub fn build(b: *std.Build) void {
    // std.debug.print("Building...\n", .{});
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "foo-bar",
        .root_module = b.createModule((.{
            .root_source_file = b.path("main.zig"),
            .target = target,
            .optimize = optimize,
        })),
    });

    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    const runStep = b.step("run", "Run Command");
    runStep.dependOn(&run.step);
}

fn buildV3(b: *std.Build) void {
    // Hedef platform ve optimizasyon bilgisini komut satırından alıyoruz.
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "foo-bar",
        .root_module = b.createModule((.{
            .root_source_file = b.path("main.zig"),
            .target = target, // Komut satırından alınan parametreye göre belirlenecek
            .optimize = optimize, // Komut satırından alınan optimize seviyesine göre belirlenecek
        })),
    });

    // Stage 2: Stage 1 de tanımlanan çıktının build sistemine eklenmesi olarak düşünebiliriz.
    b.installArtifact(exe);
}

fn buildV2(b: *std.Build) void {
    // Şimdi derleme çıktısının hangi platforma özgü olacağını
    // komut satırından parametre olarak alacağız
    const target = b.standardTargetOptions(.{});
    const exe = b.addExecutable(.{
        .name = "foo-bar",
        .root_module = b.createModule((.{
            .root_source_file = b.path("main.zig"),
            .target = target, // Komut satırından alınan parametreye göre belirlenecek
        })),
    });

    // Stage 2: Stage 1 de tanımlanan çıktının build sistemine eklenmesi olarak düşünebiliriz.
    b.installArtifact(exe);
}

fn buildV1(b: *std.Build) void {
    // Stage 1: Bir tanımlama adımı olarak düşünebiliriz.
    // Örneğin exe isimli bir Compile artifaktı oluşturuyoruz.
    // Bu çalıştırılabilir bir dosya için gerekli tanımlamaları içeriyor.
    const exe = b.addExecutable(.{
        .name = "foo-bar", // Adı "foo-bar" olan bir executable oluşturuyoruz.
        .root_module = b.createModule((.{
            // İçinde main.zig dosyasını kaynak dosya olarak belirtiyoruz.
            .root_source_file = b.path("main.zig"),
            // Hedef platformu, build sisteminin çalıştığı host platformu olarak ayarlıyoruz.
            // Mesala ben bunu Windows denediğim için Windows'a özgü bir executable oluşturulacak.
            .target = b.graph.host,
        })),
    });

    // Stage 2: Stage 1 de tanımlanan çıktının build sistemine eklenmesi olarak düşünebiliriz.
    b.installArtifact(exe);
}
