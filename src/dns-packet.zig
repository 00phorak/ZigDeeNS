const std = @import("std");
const header = @import("dns-header.zig");
const q = @import("dns-question.zig");
const a = @import("dns-record.zig");
const buf = @import("buffer.zig");
const qt = @import("query-type.zig");

const DnsPacket = struct {
    header: header.DnsHeader = header.DnsHeader{},
    questions: []q.DnsQuestion = undefined,
    answers: []a.DnsRecord = undefined,
    authorities: []a.DnsRecord = undefined,
    resources: []a.DnsRecord = undefined,

    pub fn fromBuffer(buffer: buf.BytePacketBuffer) DnsPacket {
        var result: DnsPacket = .{};

        result.header.read(buffer);

        for (0..result.header.qdCount) |_| {
            var question = q.DnsQuestion.new("", qt.QueryType.fromNum(0));
            question.read(buffer);
            // push to questions
        }
    }
};
