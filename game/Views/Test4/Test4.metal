//
//  Test4.metal
//  game
//
//  Created by Jackson Tubbs on 12/6/20.
//

#include <metal_stdlib>
using namespace metal;

struct Test4ColoredVertex{
    float4 position [[position]];
    float4 color;
};
 
vertex Test4ColoredVertex test4_vertex(constant packed_float2 *position [[buffer(0)]],
                                       constant packed_float3 *color [[buffer(1)]],
                                       constant packed_float2 &transform [[buffer(2)]],
                                       constant float         &scale [[buffer(3)]],
                                       uint                   vid [[vertex_id]])
{
    Test4ColoredVertex vert;
    vert.position = float4(position[vid].x + transform.x * scale, position[vid].y - transform.y * scale, 0, scale);
    vert.color = float4(color[vid], 1);
    return vert;
}
 
fragment float4 test4_fragment(Test4ColoredVertex vert [[stage_in]])
{
    return vert.color;
}
