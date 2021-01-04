#include <metal_stdlib>
using namespace metal;
struct ps_in {
  float2 uv;
  float3 color;
};

// entry point for fragment shader.

// metal seems to need the uniform to be in the pattern
// constant <type> &<var_name> [[buffer(X))]
fragment float4 _main(ps_in in [[stage_in]],
                      constant float &uniform [[buffer(0)]])
{
  return float4(uniform, 0.0, 0.0, 1.0);
}