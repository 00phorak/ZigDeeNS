const std = @import("std");
const expect = std.testing.expect;
const net = std.net;
const posix = std.posix;

const buf = @import("buffer.zig");
const dp = @import("dns-packet.zig");

pub fn main() !void {
    var allocator = std.heap.GeneralPurposeAllocator(.{
        .safety = true,
    }){};
    const gpa = allocator.allocator();
    defer {
        const deinit_status = allocator.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAIL");
    }

    // const addr = try net.Address.parseIp("127.0.0.1", 2048);
    // const socket = try posix.socket(posix.AF.INET, posix.SOCK.DGRAM, posix.IPPROTO.UDP);
    // defer posix.close(socket);

    // try posix.bind(socket, &addr.any, addr.getOsSockLen());

    // var bytePacketBuffer: buf.BytePacketBuffer = buf.BytePacketBuffer.new(gpa);
    // // TODO: [1] trim and compare
    // const exit = "exit\r\n";

    // while (true) {
    //     // recv calls recvfrom anyways..
    //     const len = try posix.recvfrom(socket, &bytePacketBuffer.buf, 0, null, null);
    //     const input = bytePacketBuffer.buf[0..len];
    //     // TODO: [1] trim and compare
    //     if (std.mem.eql(u8, input, exit)) {
    //         return;
    //     }
    //     std.debug.print("{s}\n", .{bytePacketBuffer.buf[0..len]});
    // }

    var file = try std.fs.cwd().openFile("src/response_packet", .{});
    defer file.close();

    var buffer = buf.BytePacketBuffer.new(gpa);

    _ = try file.read(&buffer.buf);

    var packet = try dp.DnsPacket.fromBuffer(&buffer);
    defer packet.deinit(gpa);
    try std.json.stringify(&packet, .{}, std.io.getStdOut().writer());
}

// Test everything
comptime {
    std.testing.refAllDecls(@This());
}

test "test reading packet" {
    var file = try std.fs.cwd().openFile("src/response_packet", .{});
    defer file.close();

    const allocator = std.testing.allocator;
    var buffer = buf.BytePacketBuffer.new(allocator);

    _ = try file.read(&buffer.buf);

    var packet = try dp.DnsPacket.fromBuffer(&buffer);
    defer packet.deinit(allocator);
}
