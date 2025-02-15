const std = @import("std");
const header = @import("dns-header.zig");
const q = @import("dns-question.zig");
const a = @import("dns-record.zig");
const buf = @import("buffer.zig");
const qt = @import("query-type.zig");

pub const DnsPacket = struct {
    header: header.DnsHeader = header.DnsHeader{},
    questions: []q.DnsQuestion = undefined,
    answers: []a.DnsRecord = undefined,
    authorities: []a.DnsRecord = undefined,
    resources: []a.DnsRecord = undefined,

    pub fn fromBuffer(buffer: *buf.BytePacketBuffer) !DnsPacket {
        var questions: std.ArrayList(q.DnsQuestion) = std.ArrayList(q.DnsQuestion).init(buffer.allocator);
        errdefer questions.deinit();
        var answers: std.ArrayList(a.DnsRecord) = std.ArrayList(a.DnsRecord).init(buffer.allocator);
        errdefer answers.deinit();
        var authorities: std.ArrayList(a.DnsRecord) = std.ArrayList(a.DnsRecord).init(buffer.allocator);
        errdefer authorities.deinit();
        var resources: std.ArrayList(a.DnsRecord) = std.ArrayList(a.DnsRecord).init(buffer.allocator);
        errdefer resources.deinit();
        var result: DnsPacket = DnsPacket{};

        try result.header.read(buffer);

        for (0..result.header.qdCount) |_| {
            var question = q.DnsQuestion.new("", qt.QueryType.fromNum(0));

            try question.read(buffer);

            try questions.append(question);
        }

        for (0..result.header.anCount) |_| {
            const record = try a.DnsRecord.read(buffer);
            try answers.append(record);
        }

        for (0..result.header.nsCount) |_| {
            const record = try a.DnsRecord.read(buffer);
            try authorities.append(record);
        }

        for (0..result.header.arCount) |_| {
            const record = try a.DnsRecord.read(buffer);
            try resources.append(record);
        }

        result.questions = try questions.toOwnedSlice();
        result.answers = try answers.toOwnedSlice();
        result.authorities = try authorities.toOwnedSlice();
        result.resources = try resources.toOwnedSlice();
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
