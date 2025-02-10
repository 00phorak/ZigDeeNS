const std = @import("std");
const buf = @import("buffer.zig");
const qt = @import("query-type.zig");
const expect = std.testing.expect;

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
                // TODO: get IP from u32 bytes
                // maybe concat to string and parse? idk yet, need to check docu and impl of ipv4
                // ((rawAddr >> 24) & 0xFF) -> 127
                // ((rawAddr >> 16) & 0xFF) -> 0
                // ((rawAddr >> 8) & 0xFF) -> 0
                // ((rawAddr >> 0) & 0xFF) -> 1
                const addr = rawAddr >> 24;

                return DnsRecord{
                    .domain = domain,
                    .addr = addr,
                    .ttl = ttl,
                };
            },
            .UNKNOWN => {
                buffer.step(@as(usize, dataLen));
                return DnsRecord{
                    .domain = domain,
                    .qtype = qtype,
                    .dataLen = dataLen,
                    .ttl = ttl,
                };
            },
        }
    }
};

test "dnsrecord ipv4address parsing" {
    try expect(true);
}
