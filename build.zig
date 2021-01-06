const bld = @import("std").build;
const mem = @import("std").mem;
const zig = @import("std").zig;

pub fn build(b: *bld.Builder) void {
    const sokol = buildSokol(b);

    // setup a build macro for all examples.
    buildExample(b, sokol, "window");
    buildExample(b, sokol, "triangle");
    buildExample(b, sokol, "quad");
    buildExample(b, sokol, "wireframe");
    buildExample(b, sokol, "uniform");
    buildExample(b, sokol, "texture");
    buildExample(b, sokol, "scale");
}

// build sokol and stb_image
fn buildSokol(b: *bld.Builder) *bld.LibExeObjStep {
    const lib = b.addStaticLibrary("sokol", null);
    lib.linkLibC();

    // add the stb_image source.
    //
    // note:
    // the contents of the source is actually just the .h header file.
    // I renamed it to .c and add it with the STB_IMAGE_IMPLEMENTATION
    // preprocessor to link what I need as according to the stb_image docs.
    lib.addCSourceFile("src/deps/stb/stb_image.c", &[_][]const u8{
        "-D STB_IMAGE_IMPLEMENTATION",
    });

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

// build one of the exes
fn buildExample(b: *bld.Builder, sokol: *bld.LibExeObjStep, comptime name: []const u8) void {
    const e = b.addExecutable(name, "src/" ++ name ++ "/" ++ name ++ ".zig");
    e.linkLibrary(sokol);
    e.setBuildMode(b.standardReleaseOptions());
    e.addPackagePath("sokol", "src/deps/sokol/sokol.zig");
    e.addIncludeDir("src/deps/stb");
    e.install();
    b.step(name, "Run " ++ name).dependOn(&e.run().step);
}

// macOS helper function to add SDK search paths
fn macosAddSdkDirs(b: *bld.Builder, step: *bld.LibExeObjStep) !void {
    const sdk_dir = try zig.system.getSDKPath(b.allocator);
    const framework_dir = try mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/System/Library/Frameworks" });
    const usrinclude_dir = try mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/usr/include"});
    step.addFrameworkDir(framework_dir);
    step.addIncludeDir(usrinclude_dir);
}