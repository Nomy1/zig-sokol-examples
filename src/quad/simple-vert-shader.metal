#include <metal_stdlib>
using namespace metal;

struct vs_in {
  float4 pos [[attribute(0)]];
};

struct vs_out {
  float4 pos [[position]];
  float3 color;
};

// Metal uses the stage_in keyword the parameter 
// that's coming from the program.
vertex vs_out _main(vs_in in[[stage_in]]) {
  vs_out out;
  out.pos = float4(in.pos.xyz, 1.0);
  out.color = float3(0.7, 0.7, 0.0);

  return out;
}