#include <metal_stdlib>
using namespace metal;
struct vs_in {
  float4 pos [[attribute(0)]];
  float2 uv [[attribute(1)]];
};
struct vs_out {
  float4 pos [[position]];
  float2 uv;
};
struct transform {
  float model[16];
  float view[16];
  float projection[16];
};

vertex vs_out _main(vs_in in[[stage_in]], constant transform &t [[buffer(0)]]) {
  vs_out out;
  float4 v = float4(in.pos.xyz, 1.0);

  //float4x4 m = createMatrix(t.model);
  //float4x4 view = createMatrix(t.view);
  //float4x4 p = createMatrix(t.projection);

  float4x4 m;
  m[0][0] = t.model[0];
  m[0][1] = t.model[1];
  m[0][2] = t.model[2];
  m[0][3] = t.model[3];
  m[1][0] = t.model[4];
  m[1][1] = t.model[5];
  m[1][2] = t.model[6];
  m[1][3] = t.model[7];
  m[2][0] = t.model[8];
  m[2][1] = t.model[9];
  m[2][2] = t.model[10];
  m[2][3] = t.model[11];
  m[3][0] = t.model[12];
  m[3][1] = t.model[13];
  m[3][2] = t.model[14];
  m[3][3] = t.model[15];

  float4x4 view;
  view[0][0] = t.view[0];
  view[0][1] = t.view[1];
  view[0][2] = t.view[2];
  view[0][3] = t.view[3];
  view[1][0] = t.view[4];
  view[1][1] = t.view[5];
  view[1][2] = t.view[6];
  view[1][3] = t.view[7];
  view[2][0] = t.view[8];
  view[2][1] = t.view[9];
  view[2][2] = t.view[10];
  view[2][3] = t.view[11];
  view[3][0] = t.view[12];
  view[3][1] = t.view[13];
  view[3][2] = t.view[14];
  view[3][3] = t.view[15];

  float4x4 p;
  p[0][0] = t.projection[0];
  p[0][1] = t.projection[1];
  p[0][2] = t.projection[2];
  p[0][3] = t.projection[3];
  p[1][0] = t.projection[4];
  p[1][1] = t.projection[5];
  p[1][2] = t.projection[6];
  p[1][3] = t.projection[7];
  p[2][0] = t.projection[8];
  p[2][1] = t.projection[9];
  p[2][2] = t.projection[10];
  p[2][3] = t.projection[11];
  p[3][0] = t.projection[12];
  p[3][1] = t.projection[13];
  p[3][2] = t.projection[14];
  p[3][3] = t.projection[15];

  // the main transformation operation
  // ouput = projection X view X model
  float4x4 o = p * view * m;

  // Multiply input position vector to the transform matrix
  // This will transform the position, rotation, scale as determined
  // by the matrix manipulation done in the program to the uniform paramaeter.
  out.pos.x = (o[0][0] * v.x) + (o[1][0] * v.y) + (o[2][0] * v.z) + (o[3][0] * v.w);
  out.pos.y = (o[0][1] * v.x) + (o[1][1] * v.y) + (o[2][1] * v.z) + (o[3][1] * v.w);
  out.pos.z = (o[0][2] * v.x) + (o[1][2] * v.y) + (o[2][2] * v.z) + (o[3][2] * v.w);
  out.pos.w = (o[0][3] * v.x) + (o[1][3] * v.y) + (o[2][3] * v.z) + (o[3][3] * v.w);

  out.uv = in.uv;

  return out;
}

// TODO: Can't figure out how to call this from the main function...
float4x4 createMatrix(float x[]) {
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