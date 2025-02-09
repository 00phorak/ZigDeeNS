const std = @import("std");
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
};
