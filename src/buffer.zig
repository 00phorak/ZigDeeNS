const std = @import("std");
const expect = std.testing.expect;

pub const BytePacketBufferError = error{
    EndOfBuffer,
};

pub const BytePacketBuffer = struct {
    buf: [512]u8,
    pos: usize,

    pub fn new() BytePacketBuffer {
        return BytePacketBuffer{
            .buf = undefined,
            .pos = 0,
        };
    }

    fn step(self: BytePacketBuffer, steps: usize) !void {
        self.pos += steps;
    }

    fn seek(self: BytePacketBuffer, pos: usize) !void {
        self.pos = pos;
    }

    // Read a single byte and move position forward
    fn read(self: BytePacketBuffer) BytePacketBufferError!u8 {
        if (self.pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        const result = self.buf[self.pos];
        self.pos += 1;
        return result;
    }

    fn get(self: BytePacketBuffer, pos: usize) BytePacketBufferError!u8 {
        if (pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        return self.buf[pos];
    }

    // Read a range of bytes, does not modify position
    fn getRange(self: BytePacketBuffer, start: usize, len: usize) BytePacketBufferError!u8 {
        if (start + len >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        return self.buf[start..(start + len)];
    }

    // Read two bytes, step two steps forward
    fn readU16(self: BytePacketBuffer) u16 {
        const result = (@as(u16, self.read()) << 8) | (@as(u16, self.read()));

        return result;
    }

    // Read four bytes, step four steps forward
    fn readU32(self: BytePacketBuffer) u32 {
        const result = (@as(u32, self.read()) << 24) | (@as(u32, self.read()) << 16) | (@as(u32, self.read()) << 8) | (@as(u32, self.read()) << 0);

        return result;
    }
};

test "bytepacketbuffer init" {
    const buffer: BytePacketBuffer = BytePacketBuffer.new();
    try expect(512 == buffer.buf.len);
}
