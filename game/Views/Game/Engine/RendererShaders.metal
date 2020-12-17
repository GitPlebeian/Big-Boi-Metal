//
//  RendererShaders.metal
//  game
//
//  Created by Jackson Tubbs on 12/11/20.
//

#include <metal_stdlib>
using namespace metal;

struct ColoredVertex{
    float4 position [[position]];
    float4 color;
};
 
vertex ColoredVertex vertex_shader(constant packed_float2 *position [[buffer(0)]],
                                   constant packed_float3 *color [[buffer(1)]],
                                   constant packed_float2 *transform [[buffer(2)]],
                                   constant float         *rotation [[buffer(3)]],
                                   constant packed_float2 &globalTransform [[buffer(4)]],
                                   constant float         &scale [[buffer(5)]],
                                   constant float         &screenHeight [[buffer(6)]],
                                   constant float         &screenWidth [[buffer(7)]],
                                   uint                   vid [[vertex_id]])
{
    ColoredVertex vert;

    float rotationSin = sin(rotation[vid / 3] * M_PI_F / 180);
    float rotationCos = cos(rotation[vid / 3] * M_PI_F / 180);
    float positionX = position[vid].x * rotationCos - position[vid].y * rotationSin;
    float positionY = position[vid].x * rotationSin + position[vid].y * rotationCos;
    vert.position = float4(positionX / screenWidth * 2 - 1 + (transform[vid / 3].x * scale / screenWidth * 2) + (globalTransform.x * scale / screenWidth * 2),
                           positionY / screenHeight * 2 - 1 - (transform[vid / 3].y * scale / screenHeight * 2) - (globalTransform.y * scale / screenHeight * 2) + 2,
                           0,
                           scale);
    vert.color = float4(color[vid], 1);
    return vert;
}
 
fragment float4 fragment_shader(ColoredVertex vert [[stage_in]])
{
    return vert.color;
}
