#include <metal_stdlib>
using namespace metal;
struct vs_in {
  float4 pos [[attribute(0)]];
};
struct vs_out {
  float4 pos [[position]];
  float2 uv;
  float3 color;
};
vertex vs_out _main(vs_in in[[stage_in]]) {
  vs_out out;
  out.pos = float4(in.pos.xyz, 1.0);
  out.uv = in.pos.xy;
  out.color = float3(0.5, 0.5, 0.0);
  return out;
}