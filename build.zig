const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const profiler_mod = b.addModule("profiler", .{ .root_source_file = b.path("src/profilers.zig") });

    const exe = b.addExecutable(.{
        .name = "profiler_main",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addStaticLibrary(.{
        .name = "profiler",
        .root_source_file = b.path("src/profilers.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });
    lib.root_module.addImport("profiler", profiler_mod);
    exe.root_module.addImport("profiler", profiler_mod);
    b.installArtifact(lib);
    b.installArtifact(exe);
}
