const std = @import("std");
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp  = @import("sokol").app_gfx_glue;
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
        .window_title = "Scale example",
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

    // quad vertices (x,y,z)
    // (0,0) is middle of screen
    // (-1, -1) is bottom-left
    // (1, 1) is top-right
    const verts = [_]f32 {
        // positions       // texture coords
        -0.75, -0.75, 0.0,     1.0, 1.0,   
        -0.75, 0.75, 0.0,      1.0, 0.0,
        0.75, 0.75, 0.0,       0.0, 0.0,
        0.75, -0.75, 0.0,      0.0, 1.0,
    };

    const indices = [_]u16 {
        0, 1, 3,
        1, 2, 3,
    };

    // bind the vertices to the first vertex buffer.
    bindings.vertex_buffers[0] = sg.makeBuffer(.{
        .size = @sizeOf(@TypeOf(verts)),
        .content = &verts,
    });
    bindings.index_buffer = sg.makeBuffer(.{
        .type = .INDEXBUFFER,   // need to define this buffer as index buffer.
        .size = @sizeOf(@TypeOf(indices)),
        .content = &indices,
    });
    bindings.fs_images[0] = sg.allocImage();

    // embed vertex and fragment shaders.
    var shader_desc: sg.ShaderDesc = .{};
    shader_desc.vs.source = @embedFile("simple-vert-shader.metal");
    shader_desc.fs.source = @embedFile("simple-frag-shader.metal");
    shader_desc.vs.uniform_blocks[0] = sg.ShaderUniformBlockDesc {
        .size = @sizeOf([16]f32),
    };
    shader_desc.fs.images[0].type = ._2D;

    // create pipeline to use our shader.
    var pipeline_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shader_desc),
        .index_type = .UINT16, // we need this now that we use indices.
        .primitive_type = .TRIANGLE_STRIP,
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

    const scale = 0.5;

    // identify matrix changed by scale.
    var transform = [16]f32 {
        1.0 * scale, 0.0, 0.0, 0.0,
        0.0, 1.0 * scale, 0.0, 0.0,
        0.0, 0.0, 1.0 * scale, 0.0,
        0.0, 0.0, 0.0, 1.0,
    };

    sg.applyUniforms(sg.ShaderStage.VS, 0, &transform, @sizeOf([16]f32));

    sg.draw(0, 6, 1);
    sg.endPass();
    
    // commit (finalize) our instructions.
    sg.commit();
}