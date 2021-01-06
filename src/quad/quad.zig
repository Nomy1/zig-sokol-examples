const std = @import("std");
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp  = @import("sokol").app_gfx_glue;

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
        .gl_force_gles2 = true,
        .window_title = "Quad example",
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
        -0.75, -0.75, 0.0, // bottom left
        -0.75, 0.75, 0.0,  // top left
        0.75, 0.75, 0.0, // top right
        0.75, -0.75, 0.0, // bottom right
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

    // embed vertex and fragment shaders.
    const shader_desc: sg.ShaderDesc = .{
        .vs = .{
            .source = @embedFile("simple-vert-shader.metal"),
        },
        .fs = .{
            .source = @embedFile("simple-frag-shader.metal"),
        },
    };

    // create pipeline to use our shader.
    var pipeline_desc: sg.PipelineDesc = .{
        .shader = sg.makeShader(shader_desc),
        .index_type = .UINT16, // we need this now that we use indices.
        .primitive_type = .TRIANGLE_STRIP,
    };
    // set the attribute (position) that is sent to our shader
    // as a float3 type.
    pipeline_desc.layout.attrs[0].format = .FLOAT3;
    pip = sg.makePipeline(pipeline_desc);

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

    // From the documentation:
    // In the case of no instancing: num_instances should be set to 1 and base_element/num_elements are
    // amounts of vertices. 
    
    // In the case of instancing (meaning num_instances > 1), num elements is the
    // number of vertices in one instance, while base_element remains unchanged. base_element is the index
    // of the first vertex to begin drawing from.
    
    //sg_draw(int base_element, int num_elements, int num_instances)
    sg.draw(0, 6, 1);
    sg.endPass();
    
    // commit (finalize) our instructions.
    sg.commit();
}