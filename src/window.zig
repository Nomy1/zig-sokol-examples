const std = @import("std");
const sg = @import("sokol").gfx;
const sapp = @import("sokol").app;
const sgapp  = @import("sokol").app_gfx_glue;

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
        .window_title = "window example",
    });
}

export fn init() void {
    sg.setup(.{
        .context = sgapp.context(),
    });

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
    sg.beginDefaultPass(pass_action, sapp.width(), sapp.height());
    sg.endPass();
    sg.commit();
}