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

struct Test3TextureVertex {
    float4 position [[position]];
    float2 textureCords;
};

struct MapTextureVertex {
    float4 position [[position]];
    float2 textureCords;
};
 
constexpr sampler BasicSampler(coord::normalized,
                               address::repeat,
                               filter::nearest);

// MARK: Basic

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


// MARK: Cube Map

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


// MARK: Marching Squares

vertex Test3ColoredVertex test3_vertex_map_marching_squares(constant packed_float2 *position [[buffer(0)]],
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
    
    positionX = position[vid].x * cellSize;
    positionY = position[vid].y * cellSize;
    vert.position = float4(positionX / screenWidth * 2 + (globalTransform.x * scale),
                           positionY / screenHeight * 2 - (globalTransform.y * scale),
                           0,
                           scale);
    vert.color = float4(color[vid], 1);
    
    return vert;
}

fragment float4 test3_fragment_map_marching_squares(Test3ColoredVertex vert [[stage_in]])
{
    return vert.color;
}

// MARK: Grid

vertex Test3ColoredVertex test3_vertex_grid(constant packed_float2 *position [[buffer(0)]],
                                            constant packed_float2 &globalTransform [[buffer(1)]],
                                            constant float         &scale [[buffer(2)]],
                                            constant float         &screenWidth [[buffer(3)]],
                                            constant float         &screenHeight [[buffer(4)]],
                                            constant float         &cellSize [[buffer(5)]],
                                            constant packed_float4 &color [[buffer(6)]],
                                            uint                   vid [[vertex_id]])
{
    Test3ColoredVertex vert;

    vert.position = float4(position[vid].x,
                           position[vid].y,
                           0,
                           1);
    vert.color = color;
    
    return vert;
}

fragment float4 test3_fragment_grid(Test3ColoredVertex vert [[stage_in]])
{
    return vert.color;
}

// MARK: Texture

vertex Test3TextureVertex test3_vertex_texture(constant packed_float2 *position [[buffer(0)]],
                                               constant packed_float2 *textureCords [[buffer(1)]],
                                            uint                   vid [[vertex_id]])
{
    Test3TextureVertex vert;

    vert.position = float4(position[vid].x,
                  position[vid].y,
                  0,
                  1);
    vert.textureCords = float2(textureCords[vid].x, textureCords[vid].y);
    
    return vert;
}

fragment float4 test3_fragment_texture(Test3TextureVertex vert [[stage_in]],
                                       texture2d<float>  tex2D     [[ texture(0) ]],
                                       sampler           sampler2D [[ sampler(0) ]]) {
    
    float2 interpolated = float2(vert.textureCords.x, vert.textureCords.y);
    
    float4 color = tex2D.sample(sampler2D, interpolated);
    return color;
}


// MARK: Map Texture

vertex MapTextureVertex map_vertex(constant packed_float2 *posBuffer [[buffer(0)]],
                                   constant packed_float2 *texturePosBuffer [[buffer(1)]],
                                   constant packed_float2 &globalTransform [[buffer(2)]],
                                   constant float         &scale [[buffer(3)]],
                                   constant float         &screenWidth [[buffer(4)]],
                                   constant float         &screenHeight [[buffer(5)]],
                                   constant float         &cellSize [[buffer(6)]],
                                   uint vid [[vertex_id]]) {
    MapTextureVertex vert;
    
//    float positionX = posBuffer[vid].x;
//    float positionY = posBuffer[vid].y;
//
//    positionX = vert.position.x * cellSize;
//    positionY = vert.position.y * cellSize;
//    vert.position = float4(positionX / screenWidth * 2 + (globalTransform.x * scale),
//                           positionY / screenHeight * 2 - (globalTransform.y * scale),
//                           0,
//                           scale);
//    vert.position = float4(positionX / screenWidth * 2,
//                           positionY / screenHeight * 2,
//                           0,
//                           1);
    vert.position = float4(posBuffer[vid].x * cellSize / screenWidth * 2 + (globalTransform.x * scale),
                           posBuffer[vid].y * cellSize / screenHeight * 2 - (globalTransform.y * scale),
                           0,
                           scale);
    vert.textureCords = texturePosBuffer[vid];
    return vert;
}

fragment float4 map_fragment(MapTextureVertex vert [[stage_in]],
                             texture2d<float> texture [[texture(0)]],
                             sampler           sampler2D [[ sampler(0) ]]) {
    
    float4 color = texture.sample(sampler2D, vert.textureCords);
    return color;
}


