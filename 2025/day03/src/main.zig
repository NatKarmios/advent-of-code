const std = @import("std");
const ArrayList = std.ArrayList;

fn readInput(alloc: std.mem.Allocator) anyerror!ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf: [1024]u8 = undefined;
    var reader = file.reader(&buf);

    var l: ArrayList([]const u8) = .{};
    while (try reader.interface.takeDelimiter('\n')) |line| {
        const owned = try alloc.dupe(u8, line);
        try l.append(alloc, owned);
    }
    return l;
}

fn canBubble(xs: []u8, y: u8) bool {
    var i: usize = 0;
    while (i < xs.len - 1) : (i += 1) {
        if (xs[i] < xs[i + 1]) {
            return true;
        }
    }
    return y > xs[xs.len - 1];
}

fn bubble(xs: []u8, y: u8) void {
    var i: usize = 0;
    if (!canBubble(xs, y)) {
        return;
    }
    var bubbled = false;
    while (i < xs.len - 1) : (i += 1) {
        if (xs[i] < xs[i + 1]) {
            bubbled = true;
        }
        if (bubbled) {
            xs[i] = xs[i + 1];
        }
    }
    xs[xs.len - 1] = y;
}

fn accToNum(xs: []u8) u64 {
    var total: u64 = 0;
    for (xs) |x| {
        total = (total * 10) + x;
    }
    return total;
}

fn maxJoltageForBank(bank: []const u8, numBats: comptime_int) u64 {
    // std.debug.print("{s}\n", .{bank});
    var acc: [numBats]u8 = undefined;
    for (0..numBats) |i| {
        acc[i] = 0;
    }
    var i: usize = 0;
    while (i < bank.len) : (i += 1) {
        const digit = bank[i] - '0';
        bubble(&acc, digit);
        // std.debug.print("  ({d}) {d}\n", .{ digit, accToNum(&acc) });
    }
    return accToNum(&acc);
}

fn totalJoltages(banks: ArrayList([]const u8)) [2]u64 {
    var total1: u64 = 0;
    var total2: u64 = 0;
    for (banks.items) |bank| {
        total1 += maxJoltageForBank(bank, 2);
        total2 += maxJoltageForBank(bank, 12);
    }
    return .{ total1, total2 };
}

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var banks = try readInput(alloc);
    defer {
        for (banks.items) |bank| {
            alloc.free(bank);
        }
        banks.deinit(alloc);
    }

    const total1, const total2 = totalJoltages(banks);
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{ total1, total2 });
}
