//
//  Test3.metal
//  game
//
//  Created by Jackson Tubbs on 11/30/20.
//

#include <metal_stdlib>
using namespace metal;

struct Test3ColoredVertex{
    float4 position [[position]];
    float4 color;
};
 
vertex Test3ColoredVertex test3_vertex(constant packed_float2 *position [[buffer(0)]],
                                       constant packed_float3 *color [[buffer(1)]],
                                       constant packed_float2 &transform [[buffer(2)]],
                                       constant float         &scale [[buffer(3)]],
                                       uint vid [[vertex_id]])
{
    Test3ColoredVertex vert;
    vert.position = float4(position[vid].x + transform.x * scale, position[vid].y - transform.y * scale, 0, scale);
    vert.color = float4(color[vid], 1);
    return vert;
}
 
fragment float4 test3_fragment(Test3ColoredVertex vert [[stage_in]])
{
    return vert.color;
}
