const std = @import("std");
const net = std.net;
const posix = std.posix;

pub fn main() !void {
    const addr = try net.Address.parseIp("127.0.0.1", 2048);
    const socket = try posix.socket(posix.AF.INET, posix.SOCK.DGRAM, posix.IPPROTO.UDP);
    defer posix.close(socket);

    try posix.bind(socket, &addr.any, addr.getOsSockLen());

    var buf: [1024]u8 = undefined;

    // TODO: [1] trim and compare
    const exit = "exit\r\n";

    while (true) {
        const len = try posix.recvfrom(socket, &buf, 0, null, null);
        const input = buf[0..len];
        // TODO: [1] trim and compare
        if (std.mem.eql(u8, input, exit)) {
            return;
        }
        std.debug.print("{s}\n", .{buf[0..len]});
    }
}
