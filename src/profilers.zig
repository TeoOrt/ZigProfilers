const std = @import("std");
const print = @import("std").debug.print;
const time = @import("std").time;

pub const ProfilerNode = struct {
    startTime: time.Instant = undefined,
    stopTime: time.Instant = undefined,
    name: []const u8,
    reportList: *std.ArrayList(u64),

    fn init(name: []const u8, reports: *std.ArrayList(u64)) ProfilerNode {
        return ProfilerNode{ .name = name, .reportList = reports };
    }

    pub fn start(self: *ProfilerNode) *ProfilerNode {
        self.startTime = time.Instant.now() catch unreachable;
        return self;
    }
    pub fn stop(self: *ProfilerNode) *ProfilerNode {
        self.stopTime = time.Instant.now() catch unreachable;
        return self;
    }
    pub fn report(self: *ProfilerNode) void {
        // if (self.stopTime == undefined or self.startTime == undefined) {
        //     print("Profiler was reset since then it has been restarted\n or it was never stopped\n", .{});
        //     return;
        // }
        print("Profiler Report =====================\n For profiler {s}\n", .{self.name});
        const stopTime = self.stopTime.since(self.startTime);
        print("Elapsed Time {d} ns\n", .{stopTime});
        self.reportList.*.append(stopTime) catch return;
    }
    pub fn reset(self: *ProfilerNode) void {
        self.stopTime = undefined;
        self.startTime = undefined;
    }
};

pub const Profiler = struct {
    profilers: std.StringHashMap(*ProfilerNode),
    allocator: std.mem.Allocator,
    lock: std.Thread.Mutex = std.Thread.Mutex{},

    pub fn init(allocator: std.mem.Allocator) !Profiler {
        var profilers = std.StringHashMap(*ProfilerNode).init(allocator);
        try profilers.ensureUnusedCapacity(1024);
        return Profiler{ .profilers = profilers, .allocator = allocator };
    }
    pub fn deinit(self: *Profiler) void {
        var iter = self.profilers.valueIterator();
        while (iter.next()) |value| {
            value.*.reportList.deinit();
            self.allocator.destroy(value.*.reportList);
            self.allocator.destroy(value.*);
        }
        self.profilers.deinit();
    }

    pub fn startTimer(self: *Profiler, name: []const u8) ?*ProfilerNode {
        self.lock.lock();
        defer self.lock.unlock();

        const node = self.allocator.create(ProfilerNode) catch return null;
        errdefer self.allocator.free(node);
        const list = self.allocator.create(std.ArrayList(u64)) catch return null;
        list.* = std.ArrayList(u64).init(self.allocator);
        list.*.ensureUnusedCapacity(1024) catch return null;
        node.* = ProfilerNode.init(name, list);
        self.profilers.putAssumeCapacity(name, node);

        return node;
    }
};
