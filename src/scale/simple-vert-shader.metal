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
  float model[16];
  float view[16];
  float projection[16];
};

float4x4 createMatrix(float x[16]) {
  float4x4 m;
  m[0][0] = x[0];
  m[0][1] = x[1];
  m[0][2] = x[2];
  m[0][3] = x[3];
  m[1][0] = x[4];
  m[1][1] = x[5];
  m[1][2] = x[6];
  m[1][3] = x[7];
  m[2][0] = x[8];
  m[2][1] = x[9];
  m[2][2] = x[10];
  m[2][3] = x[11];
  m[3][0] = x[12];
  m[3][1] = x[13];
  m[3][2] = x[14];
  m[3][3] = x[15];
  return m;
}

vertex vs_out _main(vs_in in[[stage_in]], constant transform &t [[buffer(0)]]) {
  vs_out out;
  float4 v = in.pos;
  float4x4 m = createMatrix(t.model);
  float4x4 v = createMatrix(t.view);
  float4x4 p = createMatrix(t.projection);
  float4x4 o = p * v * m;

  // Multiply input position vector to the transform matrix
  // This will transform the position, rotation, scale as determined
  // by the matrix manipulation done in the program to the uniform paramaeter.
  out.pos.x = (o[0] * v.x) + (o[4] * v.y) + (o[8] * v.z) + (o[12] * v.w);
  out.pos.y = (o[1] * v.x) + (o[5] * v.y) + (o[9] * v.z) + (o[13] * v.w);
  out.pos.z = (o[2] * v.x) + (o[6] * v.y) + (o[10] * v.z) + (o[14] * v.w);
  out.pos.w = (o[3] * v.x) + (o[7] * v.y) + (o[11] * v.z) + (o[15] * v.w);

  out.uv = in.uv;
  out.color = float3(o[0], 0.0, 0.0);
  return out;
}