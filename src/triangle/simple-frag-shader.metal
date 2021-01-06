#include <metal_stdlib>
using namespace metal;

struct ps_in {
  float2 uv;
  float3 color;
};

// Metal uses the stage_in keyword the parameter 
// that's coming from the vertex shader.
fragment float4 _main(ps_in in [[stage_in]])
{
  return float4(in.color.rgb, 1.0);
}
