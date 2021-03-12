//
//  Test3.metal
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

#include <metal_stdlib>
using namespace metal;


struct Test3ColoredVertex{
    float4 position [[position]];
    float4 color;
};
 
vertex Test3ColoredVertex test3_vertex_basic(constant packed_float2 *position [[buffer(0)]],
                                             constant packed_float3 *color [[buffer(1)]],
                                             constant packed_float2 *transform [[buffer(2)]],
                                             constant float         &scale [[buffer(3)]],
                                             constant float         &screenWidth [[buffer(4)]],
                                             constant float         &screenHeight [[buffer(5)]],
                                             constant packed_float2 &globalTransform [[buffer(6)]],
                                             uint                   vid [[vertex_id]])
{
    Test3ColoredVertex vert;
    
    vert.position = float4((position[vid].x / screenWidth * 2) + (globalTransform.x * scale) + (transform[vid].x),
                           (position[vid].y / screenHeight * 2) - (globalTransform.y * scale) - (transform[vid].y),
                           0,
                           scale);
    vert.color = float4(color[vid], 1);
    
    return vert;
}

fragment float4 test3_fragment_basic(Test3ColoredVertex vert [[stage_in]])
{
    return vert.color;
}


vertex Test3ColoredVertex test3_vertex_map(constant packed_float2 *position [[buffer(0)]],
                                           constant packed_float3 *color [[buffer(1)]],
                                           constant packed_float2 &globalTransform [[buffer(2)]],
                                           constant float         &scale [[buffer(3)]],
                                           constant float         &screenWidth [[buffer(4)]],
                                           constant float         &screenHeight [[buffer(5)]],
                                           constant float         &cellSize [[buffer(6)]],
                                           uint                   vid [[vertex_id]])
{
    Test3ColoredVertex vert;
    
    float positionX;
    float positionY;
    
    if (vid % 6 == 0) {
        positionX = position[vid / 6].x * cellSize;
        positionY = position[vid / 6].y * cellSize;
    } else if (vid % 6 == 1) {
        positionX = position[vid / 6].x * cellSize;
        positionY = (position[vid / 6].y + 1) * cellSize;
    } else if (vid % 6 == 2) {
        positionX = (position[vid / 6].x + 1) * cellSize;
        positionY = (position[vid / 6].y + 1) * cellSize;
    } else if (vid % 6 == 3) {
        positionX = position[vid / 6].x * cellSize;
        positionY = position[vid / 6].y * cellSize;
    } else if (vid % 6 == 4) {
        positionX = (position[vid / 6].x + 1) * cellSize;
        positionY = position[vid / 6].y * cellSize;
    } else {
        positionX = (position[vid / 6].x + 1) * cellSize;
        positionY = (position[vid / 6].y + 1) * cellSize;
    }
    vert.position = float4(positionX / screenWidth * 2 + (globalTransform.x * scale),
                           positionY / screenHeight * 2 - (globalTransform.y * scale),
                           0,
                           scale);
    vert.color = float4(color[vid / 6], 1);
    
    return vert;
}

fragment float4 test3_fragment_map(Test3ColoredVertex vert [[stage_in]])
{
    return vert.color;
}
