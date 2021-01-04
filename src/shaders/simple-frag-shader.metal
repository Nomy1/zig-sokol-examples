#include <metal_stdlib>
using namespace metal;
struct ps_in {
  float2 uv;
  float3 color;
};

fragment float4 _main(ps_in in [[stage_in]],
                      constant float &uniform [[buffer(0)]])
{
  //return tex.sample(smp, in.uv);
  return float4(uniform, 0.0, 0.0, 1.0);
}