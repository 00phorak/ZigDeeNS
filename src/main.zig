const std = @import("std");
const expect = std.testing.expect;
const net = std.net;
const posix = std.posix;
const buf = @import("buffer.zig");

pub fn main() !void {
    const addr = try net.Address.parseIp("127.0.0.1", 2048);
    const socket = try posix.socket(posix.AF.INET, posix.SOCK.DGRAM, posix.IPPROTO.UDP);
    defer posix.close(socket);

    try posix.bind(socket, &addr.any, addr.getOsSockLen());

    var bytePacketBuffer: buf.BytePacketBuffer = buf.BytePacketBuffer.new();
    // TODO: [1] trim and compare
    const exit = "exit\r\n";

    while (true) {
        // recv calls recvfrom anyways..
        const len = try posix.recvfrom(socket, &bytePacketBuffer.buf, 0, null, null);
        const input = bytePacketBuffer.buf[0..len];
        // TODO: [1] trim and compare
        if (std.mem.eql(u8, input, exit)) {
            return;
        }
        std.debug.print("{s}\n", .{bytePacketBuffer.buf[0..len]});
    }
}

// Test everything
comptime {
    std.testing.refAllDecls(@This());
}

// TODO: move Response code to separate file
test "dns response code enum" {
    try expect(@as(ResponseCode, @enumFromInt(0)) == ResponseCode.NOERROR);
    try expect(@as(ResponseCode, @enumFromInt(1)) == ResponseCode.FORMERR);
    try expect(@as(ResponseCode, @enumFromInt(2)) == ResponseCode.SERVFAIL);
    try expect(@as(ResponseCode, @enumFromInt(3)) == ResponseCode.NXDOMAIN);
    try expect(@as(ResponseCode, @enumFromInt(4)) == ResponseCode.NOTIMP);
    try expect(@as(ResponseCode, @enumFromInt(5)) == ResponseCode.REFUSED);
    // safety check for exhaustive enum
    const T = @TypeOf(@as(ResponseCode, @enumFromInt(6)));
    try expect(T == ResponseCode);
}

test "dns response code switch logic" {
    const testValue: ResponseCode = @enumFromInt(6);
    const result = switch (testValue) {
        .NOERROR, .FORMERR, .SERVFAIL, .NXDOMAIN, .REFUSED => false,
        else => true,
    };
    try expect(result);
}

const ResponseCode = enum(u3) { NOERROR, FORMERR, SERVFAIL, NXDOMAIN, NOTIMP, REFUSED, _ };

const Header = struct { packet_identifier: u16, query_response: u1, operation_code: u4, authoritative_answer: u1, truncated_message: u1, recursion_desired: u1, recursion_available: u1, reserved: u3, response_code: ResponseCode, question_count: u16, answer_count: u16, authority_count: u16, additional_count: u16 };
