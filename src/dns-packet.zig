const std = @import("std");
const header = @import("dns-header.zig");
const q = @import("dns-question.zig");
const a = @import("dns-record.zig");
const buf = @import("buffer.zig");
const qt = @import("query-type.zig");

const DnsPacket = struct {
    header: header.DnsHeader = header.DnsHeader{},
    questions: std.ArrayList(q.DnsQuestion),
    answers: std.ArrayList(a.DnsRecord),
    authorities: std.ArrayList(a.DnsRecord),
    resources: std.ArrayList(a.DnsRecord),

    pub fn fromBuffer(buffer: *buf.BytePacketBuffer) !DnsPacket {
        var result: DnsPacket = DnsPacket{
            .header = header.DnsHeader{},
            .questions = std.ArrayList(q.DnsQuestion).init(buffer.allocator),
            .answers = std.ArrayList(a.DnsRecord).init(buffer.allocator),
            .authorities = std.ArrayList(a.DnsRecord).init(buffer.allocator),
            .resources = std.ArrayList(a.DnsRecord).init(buffer.allocator),
        };

        try result.header.read(buffer);

        for (0..result.header.qdCount) |_| {
            var question = q.DnsQuestion.new("", qt.QueryType.fromNum(0));
            try question.read(buffer);

            try result.questions.append(question);
        }

        for (0..result.header.anCount) |_| {
            const record = try a.DnsRecord.read(buffer);
            try result.answers.append(record);
        }

        for (0..result.header.nsCount) |_| {
            const record = try a.DnsRecord.read(buffer);
            try result.authorities.append(record);
        }

        for (0..result.header.arCount) |_| {
            const record = try a.DnsRecord.read(buffer);
            try result.resources.append(record);
        }

        return result;
    }
};

test "read dns-packet from file" {
    const alloc = std.testing.allocator_instance.allocator();

    var file = try std.fs.cwd().openFile("src/response_packet", .{});

    var buffer = buf.BytePacketBuffer.new(alloc);

    _ = try file.read(&buffer.buf);

    _ = try DnsPacket.fromBuffer(&buffer);
    // std.log.warn("{s}", .{packet});
}
