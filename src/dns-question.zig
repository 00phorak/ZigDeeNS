const std = @import("std");
const buf = @import("buffer.zig");
const qt = @import("query-type.zig");

pub const DnsQuestion = struct {
    name: []u8,
    qtype: qt.QueryType,

    pub fn new(name: []u8, qtype: qt.QueryType) DnsQuestion {
        return DnsQuestion{
            .name = name,
            .qtype = qtype,
        };
    }

    pub fn read(self: *DnsQuestion, buffer: *buf.BytePacketBuffer) !void {
        _ = try buffer.readQName();
        const num = try buffer.readU16();
        self.qtype = qt.QueryType.fromNum(num);
        // fill in class and so on later
        _ = try buffer.readU16();
    }
};
