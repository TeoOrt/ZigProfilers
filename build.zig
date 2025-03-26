const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addStaticLibrary(.{
        .name = "profiler",
        .root_source_file = b.path("profilers.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 1, .minor = 0, .patch = 1 },
    });
    b.installArtifact(lib);
}
