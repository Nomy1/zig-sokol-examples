#include <metal_stdlib>
using namespace metal;
struct vs_in {
  float4 pos [[attribute(0)]];
  float2 uv [[attribute(1)]];
};
struct vs_out {
  float4 pos [[position]];
  float2 uv;
  float3 color;
};
struct transform {
  float value[16];
};

vertex vs_out _main(vs_in in[[stage_in]], constant transform &t [[buffer(0)]]) {
  vs_out out;
  float4 v = in.pos;

  // Multiply input position vector to the transform matrix
  // This will transform the position, rotation, scale as determined
  // by the matrix manipulation done in the program to the uniform paramaeter.
  out.pos.x = (t.value[0] * v.x) + (t.value[4] * v.y) + (t.value[8] * v.z) + (t.value[12] * v.w);
  out.pos.y = (t.value[1] * v.x) + (t.value[5] * v.y) + (t.value[9] * v.z) + (t.value[13] * v.w);
  out.pos.z = (t.value[2] * v.x) + (t.value[6] * v.y) + (t.value[10] * v.z) + (t.value[14] * v.w);
  out.pos.w = (t.value[3] * v.x) + (t.value[7] * v.y) + (t.value[11] * v.z) + (t.value[15] * v.w);

  out.uv = in.uv;
  out.color = float3(t.value[0], 0.0, 0.0);
  return out;
}