const std = @import("std");
const math = std.math;
const time = std.time;
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp  = @import("sokol").app_gfx_glue;
const zalgebra = @import("zalgebra");
const c = @cImport({
    @cInclude("stb_image.c");
});

var pip: sg.Pipeline = .{};
var bindings: sg.Bindings = .{};
var pass_action: sg.PassAction = .{};


pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .cleanup_cb = cleanup,
        .event_cb = input,
        .frame_cb = frame,
        .width = 800,
        .height = 600,
        .window_title = "Rotating Cube example",
    });
}

export fn init() void {
    // setup gfx to use the app's context (and window).
    sg.setup(.{
        .context = sgapp.context(),
    });

    // confirm we are using the expected gfx backend.
    // ex: Metal, OpenGL, DirectX, etc
    std.debug.print("Gfx using: {}\n", .{sg.queryBackend()});

    // all cube vertices.
    const vertices = [_]f32 {
        -0.5, -0.5, -0.5,  0.0, 0.0,
        0.5, -0.5, -0.5,  1.0, 0.0,
        0.5,  0.5, -0.5,  1.0, 1.0,
        0.5,  0.5, -0.5,  1.0, 1.0,
        -0.5,  0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 0.0,

        -0.5, -0.5,  0.5,  0.0, 0.0,
        0.5, -0.5,  0.5,  1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 1.0,
        -0.5,  0.5,  0.5,  0.0, 1.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,

        -0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5,  0.5, -0.5,  1.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,
        -0.5,  0.5,  0.5,  1.0, 0.0,

        0.5,  0.5,  0.5,  1.0, 0.0,
        0.5,  0.5, -0.5,  1.0, 1.0,
        0.5, -0.5, -0.5,  0.0, 1.0,
        0.5, -0.5, -0.5,  0.0, 1.0,
        0.5, -0.5,  0.5,  0.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0,

        -0.5, -0.5, -0.5,  0.0, 1.0,
        0.5, -0.5, -0.5,  1.0, 1.0,
        0.5, -0.5,  0.5,  1.0, 0.0,
        0.5, -0.5,  0.5,  1.0, 0.0,
        -0.5, -0.5,  0.5,  0.0, 0.0,
        -0.5, -0.5, -0.5,  0.0, 1.0,

        -0.5,  0.5, -0.5,  0.0, 1.0,
        0.5,  0.5, -0.5,  1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0,
        -0.5,  0.5,  0.5,  0.0, 0.0,
        -0.5,  0.5, -0.5,  0.0, 1.0,
    };

    // bind the vertices to the first vertex buffer.
    bindings.vertex_buffers[0] = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(vertices)),
        .content = &vertices,
    });

    bindings.fs_images[0] = sg.allocImage();

    // embed vertex and fragment shaders.
    var shader_desc: sg.ShaderDesc = .{};
    shader_desc.vs.source = @embedFile("simple-vert-shader.metal");
    shader_desc.fs.source = @embedFile("simple-frag-shader.metal");
    shader_desc.vs.uniform_blocks[0] = sg.ShaderUniformBlockDesc {
        .size = @sizeOf(Transform),
    };
    shader_desc.fs.images[0].type = ._2D;

    // create pipeline to use our shader.
    var pipeline_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shader_desc),
        .depth_stencil = .{
            .depth_compare_func = .LESS_EQUAL,
            .depth_write_enabled = true,
        }
    };

    // set the attribute (position) that is sent to our shader
    // as a float3 type.
    pipeline_desc.layout.attrs[0].format = .FLOAT3;
    
    // set attribute for texture UV position and send it to our
    // shader as a float2 type.
    pipeline_desc.layout.attrs[1].format = .FLOAT2;

    // capture image properties
    var imgWidth:c_int = 0;
    var imgHeight:c_int = 0;
    var desiredBytesPerPixel:c_int = 4;
    var actualBytesPerPixel:c_int = undefined;

    // load pixels.
    const pixels = c.stbi_load("res/awesomeface.png", &imgWidth, &imgHeight, &actualBytesPerPixel, desiredBytesPerPixel);

    var img_desc: sg.ImageDesc = .{};
    img_desc.type = ._2D;
    img_desc.width = imgWidth;
    img_desc.height = imgHeight;
    img_desc.pixel_format = .RGBA8;
    img_desc.wrap_u = .REPEAT;
    img_desc.wrap_v = .REPEAT;
    img_desc.min_filter = .LINEAR;
    img_desc.mag_filter = .LINEAR;
    img_desc.content.subimage[0][0].ptr = pixels;
    img_desc.content.subimage[0][0].size = 512 * 512 * actualBytesPerPixel;

    sg.initImage(bindings.fs_images[0], img_desc);

    pip = sg.makePipeline(pipeline_desc);

    // free after passing the data to the pipeline.
    c.stbi_image_free(pixels);

    // set the clear pass action's color.
    pass_action.colors[0] = .{
        .action = .CLEAR,
        .val = .{0.2, 0.3, 0.3, 1.0},
    };
}

export fn cleanup() void {
    sg.shutdown();
}

export fn input(ev: ?*const sapp.Event) void {
    const event = ev.?;
    if(event.type == .KEY_DOWN and event.key_code == .ESCAPE){
        sapp.quit();
    }
}

export fn frame() void {
    // first pass.
    sg.beginDefaultPass(pass_action, sapp.width(), sapp.height());
    sg.applyPipeline(pip);
    sg.applyBindings(bindings);

    // capture timestamp and divide by 10 to slow down the rotation
    const currTimeInt = @divFloor(time.milliTimestamp(), 10);
    const rotateDeg = @mod(currTimeInt, 360);
    const currTimeFloat = @intToFloat(f32, rotateDeg);
    const rotateDirVec = zalgebra.vec3{ .x=0.2, .y=0.8, .z=0.1 };

    // create model matrix and rotate it.
    var model = zalgebra.mat4.from_rotation(currTimeFloat, rotateDirVec);

    // create translation matrix
    const translation = zalgebra.vec3{ .x=0.0, .y=0.0, .z=-2.0 };
    const view = zalgebra.mat4.identity().translate(translation);

    // create projection matrix.
    const projection = zalgebra.mat4.perspective(45.0, 800.0/600.0, 0.1, 100.0);

    // stuff our matrices into a struct to send to the vertex shader program.
    var t = Transform {
        // the matrix data in this program differs from the shader's interpretation of a matrix.
        // Therefore we change it to a format both programs understand
        // a float array.
        .model = @ptrCast(*const [16]f32, model.get_data()).*,
        .view = @ptrCast(*const [16]f32, view.get_data()).*,
        .projection = @ptrCast(*const [16]f32, projection.get_data()).*,
    };

    // send all our data to the vertex shader.
    sg.applyUniforms(sg.ShaderStage.VS, 0, &t, @sizeOf(Transform));

    // a cube has 36 vertices (12 triangles * 3 vertices = 36 total)
    sg.draw(0, 36, 1);
    sg.endPass();
    
    // commit (finalize) our instructions.
    sg.commit();
}

// wrap the uniform data that we want to send to the vertex shader in a struct
const Transform = struct {
    model: [16]f32,
    view: [16]f32,
    projection: [16]f32,
};
