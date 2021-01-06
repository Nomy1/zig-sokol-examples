#include <metal_stdlib>
using namespace metal;

struct vs_in {
  float4 pos [[attribute(0)]];
};

// The vertex shader has no need to create a struct
// for the fragment shader in this case since
// we do not care about anything other than position.
vertex float4 _main(vs_in in[[stage_in]]) {
  return float4(in.pos.xyz, 1.0);
}