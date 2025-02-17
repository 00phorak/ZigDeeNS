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

    /// Init new BytePacketBuffer object
    pub fn new(allocator: std.mem.Allocator) BytePacketBuffer {
        return BytePacketBuffer{ .allocator = allocator };
    }

    /// Step the buffer forward by a number of steps
    pub fn step(self: *BytePacketBuffer, steps: usize) BytePacketBufferError!void {
        if (self.pos + steps >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        self.pos += steps;
    }

    /// Set buffer position
    fn seek(self: *BytePacketBuffer, pos: usize) BytePacketBufferError!void {
        if (pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        self.pos = pos;
    }

    /// Read a single byte and move position forward
    fn read(self: *BytePacketBuffer) BytePacketBufferError!u8 {
        if (self.pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        const result = self.buf[self.pos];
        self.pos += 1;
        return result;
    }

    /// Write single byte (u8) to a buffer
    pub fn write(self: *BytePacketBuffer, val: u8) BytePacketBufferError!void {
        if (self.pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        self.buf[self.pos] = val;
        self.pos += 1;
    }

    /// Write two bytes (u16) to a buffer
    pub fn writeU16(self: *BytePacketBuffer, val: u16) BytePacketBufferError!void {
        self.write(@as(u8, @intCast(val >> 8)) & 0xFF);
        self.write(@as(u8, @intCast(val >> 0)) & 0xFF);
    }

    /// Write two bytes (u16) to a buffer
    pub fn writeU32(self: *BytePacketBuffer, val: u32) BytePacketBufferError!void {
        self.write(@as(u8, @intCast(val >> 24)) & 0xFF);
        self.write(@as(u8, @intCast(val >> 16)) & 0xFF);
        self.write(@as(u8, @intCast(val >> 8)) & 0xFF);
        self.write(@as(u8, @intCast(val >> 0)) & 0xFF);
    }

    /// Get byte at current position
    pub fn get(self: *BytePacketBuffer, pos: usize) BytePacketBufferError!u8 {
        if (pos >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }
        return self.buf[pos];
    }

    /// Read a range of bytes, does not modify position
    pub fn getRange(self: *BytePacketBuffer, start: usize, len: usize) ![]u8 {
        if (start + len >= 512) {
            return BytePacketBufferError.EndOfBuffer;
        }

        const res = try self.allocator.alloc(u8, len);
        @memcpy(res, self.buf[start..(start + len)]);

        // var result = std.ArrayList(u8).init(self.allocator);
        // try result.appendSlice(self.buf[start..(start + len)]);
        // return result.toOwnedSlice();
        return res;
    }

    /// Read two bytes, step two steps forward
    pub fn readU16(self: *BytePacketBuffer) BytePacketBufferError!u16 {
        const bytes = self.read() catch |err| return {
            std.log.err("self.pos: {d}\n", .{self.pos});
            return err;
        };

        const first: u16 = @as(u16, @intCast(bytes)) << 8;
        const secondBytes = self.read() catch |err| return {
            std.log.err("self.pos: {d}\n", .{self.pos});
            return err;
        };
        const second: u16 = @intCast(secondBytes);
        const result: u16 = first | second;

        return result;
    }

    /// Read four bytes, step four steps forward
    pub fn readU32(self: *BytePacketBuffer) BytePacketBufferError!u32 {
        const first: u32 = @as(u32, @intCast(try self.read())) << 24;
        const second: u32 = @as(u32, @intCast(try self.read())) << 16;
        const third: u32 = @as(u32, @intCast(try self.read())) << 8;
        const fourth: u32 = @as(u32, @intCast(try self.read())) << 0;

        const result: u32 = first | second | third | fourth;

        return result;
    }

    pub fn readQName(self: *BytePacketBuffer) ![]u8 {
        var currPos = self.pos;
        var result = std.ArrayList(u8).init(self.allocator);
        errdefer result.deinit();

        var jumped = false;
        const maxJumps = 5;
        var currJumps: u8 = 0;

        var delim: []const u8 = "";

        while (true) {
            if (currJumps > maxJumps) {
                return BytePacketBufferError.JumpsExceeded;
            }

            const len = try self.get(currPos);

            if ((len & 0xC0) == 0xC0) {
                if (!jumped) {
                    try self.seek(currPos + 2);
                }

                const b2: u16 = @intCast(try self.get(currPos + 1));

                currPos = @as(usize, ((@as(u16, @intCast(len)) ^ 0xc0) << 8) | b2);

                jumped = true;
                currJumps += 1;
                continue;
            } else {
                currPos += 1;

                if (len == 0) {
                    break;
                }

                try result.appendSlice(delim);
                const strBuffer = try self.getRange(currPos, @as(usize, len));
                defer self.allocator.free(strBuffer);
                try result.appendSlice(strBuffer);

                delim = ".";

                currPos += @as(usize, len);
            }
        }

        if (!jumped) {
            try self.seek(currPos);
        }
        return result.toOwnedSlice();
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
    try buffer.step(10);
    try expect(10 == buffer.pos);
    try buffer.step(10);
    try expect(20 == buffer.pos);
    try buffer.seek(5);
    try expect(5 == buffer.pos);
    const readVal = try buffer.read();
    try expect(0 == readVal);
}
