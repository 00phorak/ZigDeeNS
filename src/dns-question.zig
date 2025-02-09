const std = @import("std");
const buf = @import("buffer.zig");
const qt = @import("query-type.zig");

const DnsQuestion = struct {
    name: []u8,
    qtype: qt.QueryType,

    pub fn new(name: []u8, qtype: qt.QueryType) DnsQuestion {
        return DnsQuestion{
            .name = name,
            .qtype = qtype,
        };
    }

    pub fn read(self: *DnsQuestion, buffer: buf.BytePacketBuffer) !void {
        try buffer.read_qname(self.name);
        self.qtype = try qt.QueryType.fromNum(buffer.readU16());
        // fill in class and so on later
        _ = try buffer.readU16();
    }
};
