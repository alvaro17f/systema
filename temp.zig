const std = @import("std"); pub fn main() { const x = @typeInfo(std.io); @compileLog(x); }
