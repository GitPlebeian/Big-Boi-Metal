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
                                       constant float         &cellWidth [[buffer(4)]],
                                       constant float         &cellHeight [[buffer(5)]],
                                       uint                   vid [[vertex_id]])
{
    Test4ColoredVertex vert;
    int cube = vid / 6;
    int corner = vid % 6;
    int triangle = corner / 3;
    int xMultiplier = corner % 2;
    int yMultiplier = corner / 2;
    vert.position = float4(position[cube].x + cellWidth * xMultiplier + transform.x * scale, position[cube].y + cellHeight * yMultiplier - cellHeight * triangle - transform.y * scale, 0, scale);
    vert.color = float4(color[vid / 6], 1);
    return vert;
}
 
fragment float4 test4_fragment(Test4ColoredVertex vert [[stage_in]])
{
    return vert.color;
}
