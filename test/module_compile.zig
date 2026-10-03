//! Forced-analysis compile check for the whole `wayland` module.
//!
//! The test step only analyses the declarations its own tests reach, so a
//! public function that no in-tree test calls can hold a type error that the
//! repository build never shows. Consumers find it instead. refAllDecls is
//! shallow, so this descends into each namespace and each type in it to pull
//! the methods into analysis.
//!
//! build.zig compiles this twice: free of libc, and with libc linked. The
//! library calls raw Linux syscalls, and `std.posix.system` becomes `std.c`
//! when libc is linked, which changes the syscall return types.

const std = @import("std");
const wayland = @import("wayland");

fn refDeep(comptime T: type) void {
    std.testing.refAllDecls(T);
    inline for (@typeInfo(T).@"struct".decls) |decl| {
        const field = @field(T, decl.name);
        if (@TypeOf(field) == type and @typeInfo(field) == .@"struct") {
            std.testing.refAllDecls(field);
        }
    }
}

test "every wayland declaration compiles" {
    refDeep(wayland);
    inline for (@typeInfo(wayland).@"struct".decls) |decl| {
        const namespace = @field(wayland, decl.name);
        if (@TypeOf(namespace) == type and @typeInfo(namespace) == .@"struct") {
            refDeep(namespace);
        }
    }
}
