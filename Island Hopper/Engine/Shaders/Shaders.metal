//
//  Test3.metal
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

#include <metal_stdlib>
using namespace metal;


struct ColoredVertex {
    float4 position [[position]];
    float4 color;
};

struct TextureVertex {
    float4 position [[position]];
    float2 textureCords;
};

constexpr sampler BasicSampler(coord::normalized,
                               address::repeat,
                               filter::nearest);

// MARK: Basic

vertex ColoredVertex basic_vertex(constant packed_float2 *position [[buffer(0)]],
                                  constant packed_float3 *color [[buffer(1)]],
                                  constant packed_float2 *transform [[buffer(2)]],
                                  constant float         &scale [[buffer(3)]],
                                  constant float         &screenWidth [[buffer(4)]],
                                  constant float         &screenHeight [[buffer(5)]],
                                  constant packed_float2 &globalTransform [[buffer(6)]],
                                  uint                   vid [[vertex_id]])
{
    ColoredVertex vert;
    
    vert.position = float4((position[vid].x / screenWidth * 2) + (globalTransform.x * scale) + (transform[vid].x),
                           (position[vid].y / screenHeight * 2) - (globalTransform.y * scale) - (transform[vid].y),
                           0,
                           scale);
    vert.color = float4(color[vid], 1);
    
    return vert;
}

fragment float4 basic_fragment(ColoredVertex vert [[stage_in]])
{
    return vert.color;
}


// MARK: Marching Squares

vertex ColoredVertex map_marching_squares_vertex(constant packed_float2 *position [[buffer(0)]],
                                                 constant packed_float3 *color [[buffer(1)]],
                                                 constant packed_float2 &globalTransform [[buffer(2)]],
                                                 constant float         &scale [[buffer(3)]],
                                                 constant float         &screenWidth [[buffer(4)]],
                                                 constant float         &screenHeight [[buffer(5)]],
                                                 constant float         &cellSize [[buffer(6)]],
                                                 uint                   vid [[vertex_id]])
{
    ColoredVertex vert;
    
    float positionX;
    float positionY;
    
    positionX = position[vid].x * cellSize;
    positionY = position[vid].y * cellSize;
    vert.position = float4(positionX / screenWidth * 2 + (globalTransform.x * scale),
                           positionY / screenHeight * 2 - (globalTransform.y * scale),
                           0,
                           scale);
    vert.color = float4(color[vid], 1);
    
    return vert;
}

fragment float4 map_marching_squares_fragment(ColoredVertex vert [[stage_in]])
{
    return vert.color;
}

// MARK: Grid

vertex ColoredVertex grid_vertex(constant packed_float2 *position [[buffer(0)]],
                                 constant packed_float2 &globalTransform [[buffer(1)]],
                                 constant float         &scale [[buffer(2)]],
                                 constant float         &screenWidth [[buffer(3)]],
                                 constant float         &screenHeight [[buffer(4)]],
                                 constant float         &cellSize [[buffer(5)]],
                                 constant packed_float4 &color [[buffer(6)]],
                                 uint                   vid [[vertex_id]])
{
    ColoredVertex vert;
    
    vert.position = float4(position[vid].x,
                           position[vid].y,
                           0,
                           1);
    vert.color = color;
    
    return vert;
}

fragment float4 grid_fragment(ColoredVertex vert [[stage_in]])
{
    return vert.color;
}

// MARK: Texture

vertex TextureVertex texture_vertex(constant packed_float2 *position [[buffer(0)]],
                                    constant packed_float2 *textureCords [[buffer(1)]],
                                    uint                   vid [[vertex_id]])
{
    TextureVertex vert;
    
    vert.position = float4(position[vid].x,
                           position[vid].y,
                           0,
                           1);
    vert.textureCords = float2(textureCords[vid].x, textureCords[vid].y);
    
    return vert;
}

fragment float4 texture_fragment(TextureVertex vert [[stage_in]],
                                 texture2d<float>  tex2D     [[ texture(0) ]]) {
    
    float2 interpolated = float2(vert.textureCords.x, vert.textureCords.y);
    
    float4 color = tex2D.sample(BasicSampler, interpolated);
    return color;
}


// MARK: Map Movable Texture

vertex TextureVertex map_movable_texture_vertex(constant packed_float2 *posBuffer [[buffer(0)]],
                                                constant packed_float2 *texturePosBuffer [[buffer(1)]],
                                                constant packed_float2 &globalTransform [[buffer(2)]],
                                                constant float         &scale [[buffer(3)]],
                                                constant float         &screenWidth [[buffer(4)]],
                                                constant float         &screenHeight [[buffer(5)]],
                                                constant float         &cellSize [[buffer(6)]],
                                                uint vid [[vertex_id]]) {
    TextureVertex vert;
    
    vert.position = float4(posBuffer[vid].x + globalTransform.x * scale,
                           posBuffer[vid].y - globalTransform.y * scale,
                           0,
                           scale);
    
    vert.textureCords = texturePosBuffer[vid];
    return vert;
}

fragment float4 map_movable_texture_fragment(TextureVertex    vert    [[stage_in]],
                                             texture2d<float> texture [[texture(0)]]) {
    float4 color = texture.sample(BasicSampler, vert.textureCords);
    return color;
}

// MARK: Map Texture

vertex TextureVertex map_vertex(constant packed_float2 *posBuffer [[buffer(0)]],
                                constant packed_float2 *texturePosBuffer [[buffer(1)]],
                                constant packed_float2 &globalTransform [[buffer(2)]],
                                constant float         &scale [[buffer(3)]],
                                constant float         &screenWidth [[buffer(4)]],
                                constant float         &screenHeight [[buffer(5)]],
                                constant float         &cellSize [[buffer(6)]],
                                uint vid [[vertex_id]]) {
    TextureVertex vert;
    
    vert.position = float4(posBuffer[vid].x,
                           posBuffer[vid].y,
                           0,
                           1);
    
    vert.textureCords = texturePosBuffer[vid];
    return vert;
}

fragment float4 map_fragment(TextureVertex vert [[stage_in]],
                             texture2d<float> texture [[texture(0)]],
                             sampler           sampler2D [[ sampler(0) ]]) {
    
    float4 color = texture.sample(sampler2D, vert.textureCords);
    return color;
}

// MARK: Celled Texture



