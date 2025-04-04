const std = @import("std");
const profiler = @import("profiler");

var profilerList: profiler.Profiler = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    profilerList = try profiler.Profiler.init(alloc);
    defer profilerList.deinit();

    const prof1 = profilerList.getProfiler("Test1").?.start();
    std.time.sleep(std.time.ns_per_s);
    prof1.*.stop().report();

    // a.init();
}
