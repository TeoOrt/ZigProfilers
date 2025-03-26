const std = @import("std");

const Profiler = struct {
    start_time: i128,
    stop_time: i128,
    pub fn init() Profiler {
        return Profiler{ .start_time = 0, .stop_time = 0 };
    }
    pub fn start(self: *Profiler) void {
        self.start_time = std.time.nanoTimestamp();
    }

    pub fn stop(self: *Profiler) i128 {
        self.stop_time = std.time.nanoTimestamp() - self.start_time;
        return self.stop_time;
    }

    pub fn print_time_elapsed(self: *Profiler) void {
        std.debug.print("Elapsed time: {d} ms\n", .{@divFloor(self.stop_time, std.time.ns_per_ms)});
    }
};
