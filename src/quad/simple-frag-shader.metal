#include <metal_stdlib>
using namespace metal;

struct ps_in {
  float3 color;
};

// Metal uses the stage_in keyword the parameter 
// that's coming from the vertex shader.
fragment float4 _main(ps_in in [[stage_in]])
{
  // for the to-be-rendered pixels we choose to
  // simply render it as the color we passed in
  // from the vertex shader.
  return float4(in.color.rgb, 1.0);
}
