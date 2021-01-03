#define SOKOL_IMPL
#define SOKOL_NO_ENTRY
#if defined(_WIN32)
    #define SOKOL_WIN32_FORCE_MAIN
    #define SOKOL_D3D11
    #define SOKOL_LOG(msg) OutputDebugStringA(msg)
#elif defined(__APPLE__)
    #define SOKOL_METAL
#else
    #define SOKOL_GLCORE33
#endif
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_time.h"
#include "sokol_audio.h"
