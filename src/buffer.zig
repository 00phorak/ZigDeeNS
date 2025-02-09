const std = @import("std");
const expect = std.testing.expect;

pub const BytePacketBufferError = error{
    EndOfBuffer,
};

pub const BytePacketBuffer = struct {
    buf: [512]u8,
    pos: usize,

    /// Init new BytePacketBuffer object
    pub fn new() BytePacketBuffer {
        return BytePacketBuffer{
            .buf = undefined,
            .pos = 0,
        };
    }

    /// Modify position by stepping over by number of steps
    pub fn step(self: BytePacketBuffer, steps: usize) !void {
        self.pos += steps;
    }

    /// Set position to given position
    pub fn seek(self: BytePacketBuffer, pos: usize) !void {
        self.pos = pos;
    }

    /// Read a single byte and move position forward
    pub fn read(self: BytePacketBuffer) BytePacketBufferError!u8 {
        if (self.pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        const result = self.buf[self.pos];
        self.pos += 1;
        return result;
    }

    /// Get byte at current position
    pub fn get(self: BytePacketBuffer, pos: usize) BytePacketBufferError!u8 {
        if (pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        return self.buf[pos];
    }

    /// Read a range of bytes, does not modify position
    pub fn getRange(self: BytePacketBuffer, start: usize, len: usize) BytePacketBufferError!u8 {
        if (start + len >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        return self.buf[start..(start + len)];
    }

    /// Read two bytes, step two steps forward
    pub fn readU16(self: BytePacketBuffer) u16 {
        const result = (@as(u16, self.read()) << 8) | (@as(u16, self.read()));

        return result;
    }

    /// Read four bytes, step four steps forward
    pub fn readU32(self: BytePacketBuffer) u32 {
        const result = (@as(u32, self.read()) << 24) | (@as(u32, self.read()) << 16) | (@as(u32, self.read()) << 8) | (@as(u32, self.read()) << 0);

        return result;
    }
};

test "bytepacketbuffer init" {
    const buffer: BytePacketBuffer = BytePacketBuffer.new();
    try expect(512 == buffer.buf.len);
}
