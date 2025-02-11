const std = @import("std");
const expect = std.testing.expect;

const buf = @import("buffer.zig");
const qt = @import("query-type.zig");

const DnsRecordTag = enum {
    UNKNOWN,
    A,
};

const DnsRecord = union(DnsRecordTag) {
    UNKNOWN: struct {
        domain: []u8,
        qtype: u16,
        dataLen: u16,
        ttl: u32,
    },
    A: struct {
        domain: []u8,
        addr: std.net.Ip4Address,
        ttl: u32,
    },

    pub fn read(buffer: buf.BytePacketBuffer) DnsRecord {
        const domain = buffer.readQName();

        const qtype_num = buffer.readU16();
        const qtype = qt.QueryType.fromNum(qtype_num);
        _ = buffer.readU16();
        const ttl = buffer.readU32();
        const dataLen = buffer.readU16();

        switch (qtype) {
            .A => {
                const rawAddr = buffer.readU32();
                // ((rawAddr >> 24) & 0xFF) -> 127
                // ((rawAddr >> 16) & 0xFF) -> 0
                // ((rawAddr >> 8) & 0xFF) -> 0
                // ((rawAddr >> 0) & 0xFF) -> 1
                const parsedAddr: [4]u8 = .{
                    ((rawAddr >> 0) & 0xFF),
                    ((rawAddr >> 8) & 0xFF),
                    ((rawAddr >> 16) & 0xFF),
                    ((rawAddr >> 24) & 0xFF),
                };
                const addr = std.net.Ip4Address.init(parsedAddr, 80);

                return DnsRecord{.A{
                    .domain = domain,
                    .addr = addr,
                    .ttl = ttl,
                }};
            },
            .UNKNOWN => {
                buffer.step(@as(usize, dataLen));
                return DnsRecord{.UNKNOWN{
                    .domain = domain,
                    .qtype = qtype,
                    .dataLen = dataLen,
                    .ttl = ttl,
                }};
            },
        }
    }
};

test "dnsrecord ipv4address parsing" {
    // 127.0.0.1
    const rawAddr: u32 = 0b01111111000000000000000000000001;
    const parsedAddr: [4]u8 = .{
        ((rawAddr >> 0) & 0xFF),
        ((rawAddr >> 8) & 0xFF),
        ((rawAddr >> 16) & 0xFF),
        ((rawAddr >> 24) & 0xFF),
    };
    const addr = std.net.Ip4Address.init(parsedAddr, 80);
    try expect(addr.sa.addr == rawAddr);
}
