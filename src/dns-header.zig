const std = @import("std");
const rescode = @import("rescode.zig");
const buffer = @import("buffer.zig");

pub const DnsHeader = struct {
    /// ID
    /// identifier
    /// 16 bits
    id: u16 = 0,

    // Flags

    /// Query/Reply flag
    /// 1 bit
    qr: bool = false,

    /// Operation code
    /// Standard query = 0
    /// Inverse query = 1
    /// Serer status = 2
    /// 4 bits
    opcode: u4 = 0,

    /// Authoritative answer flag
    /// 1 bit
    aa: bool = false,

    /// Truncation falg
    /// if message was truncated
    /// 1 bit
    tc: bool = false,

    /// Recursion desired
    /// if the client means a recursive query
    /// 1 bit
    rd: bool = false,

    /// Recursion available
    /// if DNS server supports recursion
    /// 1 bit
    ra: bool = false,

    /// Zero 1 bit, reserved for future use
    /// 1 bit
    z: u1 = 0,

    /// Authentic data
    /// if server verified the data
    /// 1 bit
    ad: bool = false,

    /// Checking disabled
    /// if a non-verified data is acceptable in a response
    /// 1 bit
    cd: bool = false,

    /// Response code
    /// 4 bits
    rcode: rescode.ResponseCode = rescode.ResponseCode.NO_ERROR,

    /// Question count
    /// number of questions
    /// 16 bits
    qdCount: u16 = 0,

    /// Answer record count
    /// number of answers
    /// 16 bits
    anCount: u16 = 0,

    /// Authority record count
    /// number of authority resource records
    /// 16 bits
    nsCount: u16 = 0,

    /// Additional record count
    /// number of additional resource records
    /// 16 bits
    arCount: u16 = 0,

    pub fn read(self: *DnsHeader, buf: *buffer.BytePacketBuffer) !void {
        // read first 16 bits = ID
        self.id = try buf.readU16();

        // next 16 bits are flags
        const flags = try buf.readU16();
        // shift left to get first 8 bits
        const a: u8 = @intCast(flags >> 8);
        // compare with 'ones' to get the second part of bits from the u16
        const b: u8 = @intCast(flags & 0xFF);
        // get each flag one by one
        // get '1', shift it to the position of the flag and the compare with the value in 'a'
        // then compare with 0
        self.rd = (a & (1 << 0)) > 0;
        self.tc = (a & (1 << 1)) > 0;
        self.aa = (a & (1 << 2)) > 0;
        // opcode is 4 bits at position 3, thats why shift by 3 and 'and' with 0x0F
        self.opcode = @intCast((a >> 3) & 0x0F);
        // then skip the 4 bits from the opcode
        self.qr = (a & (1 << 7)) > 0;

        // same as before, but we dont have to shift
        self.rcode = @enumFromInt(b & 0x0f);
        self.cd = (b & (1 << 4)) > 0;
        self.ad = (b & (1 << 5)) > 0;
        self.z = @intCast(b & (1 << 6));
        self.ra = (b & (1 << 7)) > 0;

        self.qdCount = try buf.readU16();
        self.anCount = try buf.readU16();
        self.nsCount = try buf.readU16();
        self.arCount = try buf.readU16();
    }
};
