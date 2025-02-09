const std = @import("std");
const expect = std.testing.expect;

const ResponseCode = enum(u4) {
    NO_ERROR,
    FORMAT_ERROR,
    SERVER_FAILURE,
    NAME_ERROR,
    NOT_IMPLEMENTED,
    REFUSED,
    YX_DOMAIN,
    YX_RR_SET,
    NX_RR_SET,
    NOT_AUTH,
    NOT_ZONE,
    _,
};

test "dns response code enum" {
    try expect(@as(ResponseCode, @enumFromInt(0)) == ResponseCode.NO_ERROR);
    try expect(@as(ResponseCode, @enumFromInt(1)) == ResponseCode.FORMAT_ERROR);
    try expect(@as(ResponseCode, @enumFromInt(2)) == ResponseCode.SERVER_FAILURE);
    try expect(@as(ResponseCode, @enumFromInt(3)) == ResponseCode.NAME_ERROR);
    try expect(@as(ResponseCode, @enumFromInt(4)) == ResponseCode.NOT_IMPLEMENTED);
    try expect(@as(ResponseCode, @enumFromInt(5)) == ResponseCode.REFUSED);
    try expect(@as(ResponseCode, @enumFromInt(6)) == ResponseCode.YX_DOMAIN);
    try expect(@as(ResponseCode, @enumFromInt(7)) == ResponseCode.YX_RR_SET);
    try expect(@as(ResponseCode, @enumFromInt(8)) == ResponseCode.NX_RR_SET);
    try expect(@as(ResponseCode, @enumFromInt(9)) == ResponseCode.NOT_AUTH);
    try expect(@as(ResponseCode, @enumFromInt(10)) == ResponseCode.NOT_ZONE);
    // safety check for exhaustive enum
    const T = @TypeOf(@as(ResponseCode, @enumFromInt(11)));
    try expect(T == ResponseCode);
}
