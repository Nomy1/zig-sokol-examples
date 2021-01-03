const bld = @import("std").build;
const mem = @import("std").mem;
const zig = @import("std").zig;

pub fn build(b: *bld.Builder) void {
    const sokol = buildSokol(b);
    buildExample(b, sokol, "window");
}

// build one of the exes
fn buildExample(b: *bld.Builder, sokol: *bld.LibExeObjStep, comptime name: []const u8) void {
    const e = b.addExecutable(name, "src/" ++ name ++ ".zig");
    e.linkLibrary(sokol);
    e.setBuildMode(b.standardReleaseOptions());
    e.addPackagePath("sokol", "src/deps/sokol/sokol.zig");
    e.install();
    b.step(name, "Run " ++ name).dependOn(&e.run().step);
}

// build sokol into a static library
fn buildSokol(b: *bld.Builder) *bld.LibExeObjStep {
    const lib = b.addStaticLibrary("sokol", null);
    lib.linkLibC();
    lib.setBuildMode(b.standardReleaseOptions());
    if (lib.target.isDarwin()) {
        macosAddSdkDirs(b, lib) catch unreachable;
        lib.addCSourceFile("src/deps/sokol/sokol.c", &[_][]const u8 { "-ObjC" });
        lib.linkFramework("MetalKit");
        lib.linkFramework("Metal");
        lib.linkFramework("Cocoa");
        lib.linkFramework("QuartzCore");
        lib.linkFramework("AudioToolbox");
    }
    else {
        lib.addCSourceFile("src/deps/sokol/sokol.c", &[_][]const u8{});
        if (lib.target.isLinux()) {
            lib.linkSystemLibrary("X11");
            lib.linkSystemLibrary("Xi");
            lib.linkSystemLibrary("Xcursor");
            lib.linkSystemLibrary("GL");
            lib.linkSystemLibrary("asound");
        }
    }
    return lib;
}

// macOS helper function to add SDK search paths
fn macosAddSdkDirs(b: *bld.Builder, step: *bld.LibExeObjStep) !void {
    const sdk_dir = try zig.system.getSDKPath(b.allocator);
    const framework_dir = try mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/System/Library/Frameworks" });
    const usrinclude_dir = try mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/usr/include"});
    step.addFrameworkDir(framework_dir);
    step.addIncludeDir(usrinclude_dir);
}