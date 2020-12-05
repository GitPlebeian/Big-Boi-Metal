//
//  Test2.metal
//  game
//
//  Created by Jackson Tubbs on 11/28/20.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 basic_vertex(
  const device packed_float3* vertex_array [[ buffer(0) ]],
  unsigned int vid [[ vertex_id ]]) {
  return float4(vertex_array[vid], 1);
}

fragment half4 basic_fragment() {
    return half4(1, 1, 0, 1);
}

struct ColoredVertex
{
    float4 position [[position]];
    float4 color;
};
 
vertex ColoredVertex basic_vertex2(constant packed_float2 *position [[buffer(0)]],
                                 constant packed_float3 *color [[buffer(1)]],
                                 uint vid [[vertex_id]])
{
    ColoredVertex vert;
    vert.position = float4(position[vid], 0, 1);
    vert.color = float4(color[vid], 1);
    return vert;
}
 
fragment float4 basic_fragment2(ColoredVertex vert [[stage_in]])
{
    return vert.color;
}
