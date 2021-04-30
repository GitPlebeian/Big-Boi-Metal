//
//  MapLayer.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/12/21.
//

import UIKit
import Metal

class MapLayer: RenderLayer {
    
    private var map: Map
    private var touchController: EngineTouchController
    let cellSize: Float = 44
    
    private var vertexPosBuffer:  MTLBuffer!
    private var texturePosBuffer: MTLBuffer!
    private var terrainTileTexture: MTLTexture!
    
    private var vertexCords: [Float] = []
    private var textureCords: [Float] = []
    
    init(map: Map,
         touchController: EngineTouchController) {
        self.map = map
        self.touchController = touchController
        super.init()
        setupVertexTextureData()
    }
    
    override func setPipelineState() {
        self.pipelineState = RenderPipelineStateLibrary.shared.pipelineState(.Map)
    }
    
    // Render
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(pipelineState)
        
        if vertexCords.count == 0 {
            return
        }
        
        var transform = touchController.vertexTransform
        var scale     = touchController.vertexScale
        var width     = touchController.width
        var height    = touchController.height
        var gridSize  = cellSize

        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter             = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.magFilter             = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.maxAnisotropy         = 1
        samplerDescriptor.sAddressMode          = MTLSamplerAddressMode.clampToZero
        samplerDescriptor.tAddressMode          = MTLSamplerAddressMode.clampToZero
        samplerDescriptor.rAddressMode          = MTLSamplerAddressMode.clampToZero
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.lodMinClamp           = 0
        samplerDescriptor.lodMaxClamp           = .greatestFiniteMagnitude
        samplerDescriptor.mipFilter = .notMipmapped
        
        let sampler = GraphicsDevice.Device.makeSamplerState(descriptor: samplerDescriptor)!
        
        encoder.setVertexBuffer(vertexPosBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(texturePosBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&transform, length: 8, index: 2)
        encoder.setVertexBytes(&scale, length: 4, index: 3)
        encoder.setVertexBytes(&width, length: 4, index: 4)
        encoder.setVertexBytes(&height, length: 4, index: 5)
        encoder.setVertexBytes(&gridSize, length: 4, index: 6)
        encoder.setFragmentTexture(terrainTileTexture, index: 0)
        encoder.setFragmentSamplerState(sampler, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCords.count / 2)
    }
    
    // MARK: Public
    
    // MARK: Private
    
    // Setup Vertex Texture Data
    private func setupVertexTextureData() {
        setupTileMapTexture()
        
        var vertexCords:   [Float] = []
        var textureCords:  [Float] = []

        for index in 0..<(map.width) * (map.height) {

            let y = index / (map.width)
            let x = index % (map.width)
            let yFloat = Float(y)
            let xFloat = Float(x)

            let result = getTextureCordsAndVerticesCountForCorners(corners: [map.tiles[index + y],
                                                                             map.tiles[index + y + 1],
                                                                             map.tiles[index + y + map.width + 1],
                                                                             map.tiles[index + y + map.width + 2]])
            
            textureCords.append(contentsOf: result.1)
            for _ in 0..<result.0 {
                vertexCords.append(contentsOf: [xFloat, yFloat + 1,
                                                xFloat + 1, yFloat + 1,
                                                xFloat, yFloat,
                                                xFloat + 1, yFloat + 1,
                                                xFloat + 1, yFloat,
                                                xFloat, yFloat])
                
//                vertexCords.append(contentsOf: [xFloat - 0.01, yFloat + 1 + 0.01,
//                                                xFloat + 1 + 0.01, yFloat + 1 + 0.01,
//                                                xFloat - 0.01, yFloat - 0.001,
//                                                xFloat + 1 + 0.01, yFloat + 1 + 0.01,
//                                                xFloat + 1 + 0.01, yFloat - 0.01,
//                                                xFloat - 0.01, yFloat + 0.01])
            }

        }

        self.vertexCords = vertexCords
        self.textureCords = textureCords
        updateBuffers()
    }
    
    // Get Texture Cords For Cell
    private func getTextureCordsForCell(x: Int, y: Int) -> [Float] {
        let xStep = 16 / Float(terrainTileTexture.width)
        let yStep = 16 / Float(terrainTileTexture.height)
//        let xStep: Float = 16
//        let yStep: Float = 16

//        let pixelOffsetX = 0.5 / Float(terrainTileTexture.width)
//        let pixelOffsetY = 0.5 / Float(terrainTileTexture.height)
////
        let pixelOffsetX: Float = 0
        let pixelOffsetY: Float = 0
        
//        let pixelOffsetX: Float = 0.5
//        let pixelOffsetY: Float = 0.5
        
        
        let adjustedX = xStep * Float(x) + pixelOffsetX
        let adjustedY = yStep * Float(y) + pixelOffsetY
        
//        let adjustedX = xStep * x
//        let adjustedY = yStep * y
        
        let x1 = adjustedX + xStep - pixelOffsetX
        let y1 = adjustedY + yStep - pixelOffsetY
        
//        x1 -= xStep / 16
//        y1 -= yStep / 16
//
//        adjustedX += xStep / 16
//        adjustedY += yStep / 16
        
//        x1 -= xStep / 16 * 0
//        y1 -= yStep / 16 * 0
//
//        adjustedX += xStep / 16 * 0
//        adjustedY += yStep / 16 * 0
        
        return [adjustedX, adjustedY,
                x1, adjustedY,
                adjustedX, y1,
                x1, adjustedY,
                x1, y1,
                adjustedX, y1]
        
    }
    
    // Get Texture Cords and Vertices For Corners
    private func getTextureCordsAndVerticesCountForCorners(corners: [TileType]) -> (Int, [Float]) {
        var textureCords: [Float] = []
        
        var tilesToAdd: [(TileType, TileGraphicType)] = []

        let cornersSorted = corners.sorted { (left, right) -> Bool in
            return left.rawValue < right.rawValue
        }
        
        var sortedUniqueCorners: [TileType] = []
        
        for corner in cornersSorted {
            if !sortedUniqueCorners.contains(corner) {
                sortedUniqueCorners.append(corner)
            }
        }
        
        if sortedUniqueCorners.count > 2 {
            var middleLevel: TileType!
            if sortedUniqueCorners.count == 3 {
                middleLevel = sortedUniqueCorners[1]
            } else {
                middleLevel = sortedUniqueCorners[2]
            }
            tilesToAdd.append((middleLevel, .whole))
        }

        for sortedCorner in sortedUniqueCorners {
            tilesToAdd.append((sortedCorner, getGraphicsTypeForCorners(targetType: sortedCorner, corners: corners)))
        }
        
        for tileToAdd in tilesToAdd {
            let cordinate = TileHelper.getTileForDirection(tile: tileToAdd.0, graphicType: tileToAdd.1)
            textureCords.append(contentsOf: getTextureCordsForCell(x: cordinate.x, y: cordinate.y))
        }
        
        return (tilesToAdd.count, textureCords)
    }
    
    // Get Graphics Type For Corners
    private func getGraphicsTypeForCorners(targetType: TileType, corners: [TileType]) -> TileGraphicType {
        
        var config: Int = 0
        
        for (index, corner) in corners.enumerated() {
            if corner != targetType {
                continue
            }
            if index == 0 {
                config += 1
            } else if index == 1 {
                config += 2
            } else if index == 2 {
                config += 4
            } else if index == 3 {
                config += 8
            }
        }
        
        switch config {
        case 1: return .topRight
        case 2: return .topLeft
        case 4: return .bottomRight
        case 8: return .bottomLeft
            
        case 3: return .top
        case 12: return .bottom
        case 5: return .right
        case 10: return .left
            
        case 9: return .diagonalTRBL
        case 6: return .diagonalTLBR
            
        case 7: return .topRightMissing
        case 13: return .bottomRightMissing
        case 14: return .bottomLeftMissing
        case 11: return .topLeftMissing
        default:
            return .whole
        }
    }
    
    // Setup Texture
    private func setupTileMapTexture() {
        let image = UIImage(named: "terrain_tile_set")!
        let imageRef = image.cgImage!

        let width = imageRef.width
        let height = imageRef.height

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        
        
        let region = MTLRegionMake2D(0, 0, width, height)

        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let texture = GraphicsDevice.Device.makeTexture(descriptor: textureDescriptor)!
        
        texture.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: width * 4)
        terrainTileTexture = texture
    }
    
    // Update Buffers
    private func updateBuffers() {
        vertexPosBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertexCords, length: vertexCords.count * 4, options: [])
        texturePosBuffer = GraphicsDevice.Device.makeBuffer(bytes: textureCords, length: textureCords.count * 4, options: [])
    }
}
