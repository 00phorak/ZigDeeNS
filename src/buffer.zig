const std = @import("std");
const expect = std.testing.expect;

pub const BytePacketBufferError = error{
    EndOfBuffer,
    JumpsExceeded,
};

pub const BytePacketBuffer = struct {
    buf: [512]u8 = undefined,
    pos: usize = 0,
    allocator: std.mem.Allocator,
    const Self = @This();

    /// Init new BytePacketBuffer object
    pub fn new(allocator: std.mem.Allocator) BytePacketBuffer {
        return Self{ .allocator = allocator };
    }

    /// Read a single byte and move position forward
    fn read(self: *Self) BytePacketBufferError!u8 {
        if (self.pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        const result = self.buf[self.pos];
        self.pos += 1;
        return result;
    }

    /// Get byte at current position
    pub fn get(self: *Self, pos: usize) BytePacketBufferError!u8 {
        if (pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        return self.buf[pos];
    }

    /// Read a range of bytes, does not modify position
    pub fn getRange(self: *Self, start: usize, len: usize) BytePacketBufferError!u8 {
        if (start + len >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        return self.buf[start..(start + len)];
    }

    /// Read two bytes, step two steps forward
    pub fn readU16(self: *Self) u16 {
        const result = (@as(u16, self.read()) << 8) | (@as(u16, self.read()));

        return result;
    }

    /// Read four bytes, step four steps forward
    pub fn readU32(self: *Self) u32 {
        const result = (@as(u32, self.read()) << 24) | (@as(u32, self.read()) << 16) | (@as(u32, self.read()) << 8) | (@as(u32, self.read()) << 0);

        return result;
    }

    /// TODO: describe and fix working with strings... then make public
    fn readQName(self: *Self, outstr: []u8) !void {
        var currPos = self.pos;

        var jumped = false;
        const maxJumps = 5;
        var currJumps = 0;

        var delim = "";

        while (true) {
            if (currJumps > maxJumps) {
                return BytePacketBufferError.JumpsExceeded;
            }

            const len = self.get(currPos);

            if ((len & 0xC0) == 0xC0) {
                if (!jumped) {
                    self.seek(currPos + 2);
                }

                const b2 = @as(u16, self.get(currPos + 1));

                const offset = ((@as(u16, len) ^ 0xc0) << 8) | b2;
                currPos = @as(usize, offset);

                jumped = true;
                currJumps += 1;
                continue;
            } else {
                currPos += 1;

                if (len == 0) {
                    break;
                }

                outstr = try std.mem.concat(self.allocator, u8, outstr, delim);

                const strBuffer = self.getRange(currPos, @as(usize, len));
                outstr = try std.mem.concat(self.allocator, u8, outstr, strBuffer);

                delim = ".";

                currPos += @as(usize, len);
            }
        }

        if (!jumped) {
            self.seek(currPos);
        }
    }
};

test "bytepacketbuffer init" {
    const alloc = std.testing.allocator_instance.allocator();
    const buffer: BytePacketBuffer = BytePacketBuffer.new(alloc);
    try expect(512 == buffer.buf.len);
    try expect(0 == buffer.pos);
}

test "bytepacketbuffer modifying buffer" {
    const alloc = std.testing.allocator_instance.allocator();
    var buffer: BytePacketBuffer = BytePacketBuffer.new(alloc);
    try expect(0 == buffer.pos);
    buffer.pos += 10;
    try expect(10 == buffer.pos);
    buffer.pos += 10;
    try expect(20 == buffer.pos);
    buffer.pos = 5;
    try expect(5 == buffer.pos);
    const readVal = try buffer.read();
    try expect(0 == readVal);
}
