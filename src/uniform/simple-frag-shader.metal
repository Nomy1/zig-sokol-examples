#include <metal_stdlib>
using namespace metal;

// Metal uses the stage_in keyword the parameter 
// that's coming from the vertex shader.
//
// Since we only send the position from the vertex shader,
// there is no need to pass in a struct.
// The float4 parameter annoted with the stage_in tag
// will receive the float4 from the vertex shader automagically.
//
// The uniform is passed from the main program for the second parameter.
fragment float4 _main(float4 in [[stage_in]], constant float &uniform [[buffer(0)]])
{
  return float4(uniform, 0.0, 0.0, 1.0);
}
