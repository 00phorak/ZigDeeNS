const std = @import("std");
const expect = std.testing.expect;

pub const QueryType = struct {
    value: u16,

    pub fn fromNum(num: u16) QueryType {
        return QueryType{
            .value = num,
        };
    }
};
