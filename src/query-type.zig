const std = @import("std");
const expect = std.testing.expect;

const QueryTypeTag = enum {
    UNKNOWN,
    A,
};

pub const QueryType = union(QueryTypeTag) {
    UNKNOWN: u16,
    A: u1,

    pub fn fromNum(num: u16) QueryType {
        switch (num) {
            1 => return QueryType{
                .A = 1,
            },
            else => return QueryType{
                .UNKNOWN = num,
            },
        }
    }
};

test "query type union fromNum" {
    const queryType = QueryType.fromNum(1);
    try expect(1 == queryType.A);
    const queryTypeUnknown = QueryType.fromNum(10);
    try expect(10 == queryTypeUnknown.UNKNOWN);
}
