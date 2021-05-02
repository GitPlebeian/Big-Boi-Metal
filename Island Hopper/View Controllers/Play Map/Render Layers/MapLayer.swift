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
    private var mapTexture: MTLTexture!
    
    private var vertexCords: [Float] = []
    private var textureCords: [Float] = []
    
    private var renderingVertexBuffer: MTLBuffer!
    private var renderingTextureCordsBuffer: MTLBuffer!
    
    init(map: Map,
         touchController: EngineTouchController) {
        self.map = map
        self.touchController = touchController
        super.init()
        setupVertexTextureData()
        let textureCords: [Float] = [0,0,1,0,0,1,1,0,1,1,0,1]
        self.renderingTextureCordsBuffer = GraphicsDevice.Device.makeBuffer(bytes: textureCords, length: textureCords.count * 4, options: [])
    }
    
    override func setPipelineState() {
        self.pipelineState = RenderPipelineStateLibrary.shared.pipelineState(.MapMovable)
    }
    
    // Render
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        encoder.setRenderPipelineState(pipelineState)
        
        if vertexCords.count == 0 {
            return
        }
        
        var transform = touchController.vertexTransform
        var scale     = touchController.vertexScale
        var width     = touchController.width!
        var height    = touchController.height!
        var gridSize  = cellSize
        
        let xStart: Float = 0
        let yStart: Float = 0
        let xEnd = Float(map.width) * cellSize / width * 2
        let yEnd = Float(map.height) * cellSize / height * 2
        
        let vertices: [Float] = [xStart, yEnd,
                                 xEnd, yEnd,
                                 xStart, yStart,
                                 xEnd, yEnd,
                                 xEnd, yStart,
                                 xStart, yStart]
        
        self.renderingVertexBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertices, length: vertices.count * 4, options: [])
        
        encoder.setVertexBuffer(renderingVertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(renderingTextureCordsBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&transform, length: 8, index: 2)
        encoder.setVertexBytes(&scale, length: 4, index: 3)
        encoder.setVertexBytes(&width, length: 4, index: 4)
        encoder.setVertexBytes(&height, length: 4, index: 5)
        encoder.setVertexBytes(&gridSize, length: 4, index: 6)
        encoder.setFragmentTexture(mapTexture, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
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
            var yFloat = Float(y)
            var xFloat = Float(x)
            
            let xStep = 2 / Float(map.width)
            let yStep = 2 / Float(map.height)
            
            xFloat = xFloat * xStep - 1
            yFloat = yFloat * yStep - 1

            let corners = [map.tiles[index + y],
                           map.tiles[index + y + 1],
                           map.tiles[index + y + map.width + 1],
                           map.tiles[index + y + map.width + 2]]
            
            let result = getTextureCordsAndVerticesCountForCorners(corners: corners)
            
            let cornersSorted = corners.sorted { (left, right) -> Bool in
                return left.rawValue < right.rawValue
            }
            
            var sortedUniqueCorners: [TileType] = []
            
            for corner in cornersSorted {
                if !sortedUniqueCorners.contains(corner) {
                    sortedUniqueCorners.append(corner)
                }
            }
            
            var fillerMaterialCords: [Float] = []
            var fillerMaterialType: TileGraphicFillerType!
            var middleLevel: TileType!
            if sortedUniqueCorners.count > 2 {
                if sortedUniqueCorners.count == 3 {
                    middleLevel = sortedUniqueCorners[1]
                } else {
                    middleLevel = sortedUniqueCorners[2]
                }
            }
            
            // Get Filler For Middle
            if let middleLevel = middleLevel {
                for sortedCorner in sortedUniqueCorners {
                        if middleLevel == sortedCorner {
                            let fillerResult = getFillerMaterialTextureCords(corners: corners, filler: middleLevel)
                            fillerMaterialCords.append(contentsOf: fillerResult.0)
                            fillerMaterialType = fillerResult.1
                        }
                }
            }
            
            if fillerMaterialCords.count > 0 {
                var addedFillerMaterial: Bool = false
                for (index, corner) in sortedUniqueCorners.enumerated() {
                    if addedFillerMaterial == false && corner == middleLevel {
                        addedFillerMaterial = true
                        textureCords.append(contentsOf: fillerMaterialCords)
                        var x1ModOptional: Float?
                        var x2ModOptional: Float?
                        var y1ModOptional: Float?
                        var y2ModOptional: Float?
                        switch fillerMaterialType {
                        case .top: y2ModOptional = yStep / 2
                        case .bottom: y1ModOptional = -yStep / 2
                        case .whole: break
                        case .left: x2ModOptional = -xStep / 2
                        case .right: x1ModOptional = xStep / 2
                        default:
                            break
                        }
                        var x1Mod: Float = 0
                        if x1ModOptional != nil {
                            x1Mod = x1ModOptional!
                        }
                        var x2Mod: Float = 0
                        if x2ModOptional != nil {
                            x2Mod = x2ModOptional!
                        }
                        var y1Mod: Float = 0
                        if y1ModOptional != nil {
                            y1Mod = y1ModOptional!
                        }
                        var y2Mod: Float = 0
                        if y2ModOptional != nil {
                            y2Mod = y2ModOptional!
                        }
                        vertexCords.append(contentsOf: [xFloat + x1Mod, yFloat + yStep + y1Mod,
                                                        xFloat + xStep + x2Mod, yFloat + yStep + y1Mod,
                                                        xFloat + x1Mod, yFloat + y2Mod,
                                                        xFloat + xStep + x2Mod, yFloat + yStep + y1Mod,
                                                        xFloat + xStep + x2Mod, yFloat + y2Mod,
                                                        xFloat + x1Mod, yFloat + y2Mod])
                    }
                    for cordIndex in index * 12..<(index + 1) * 12 {
                        textureCords.append(result.1[cordIndex])
                    }
                    vertexCords.append(contentsOf: [xFloat, yFloat + yStep,
                                                    xFloat + xStep, yFloat + yStep,
                                                    xFloat, yFloat,
                                                    xFloat + xStep, yFloat + yStep,
                                                    xFloat + xStep, yFloat,
                                                    xFloat, yFloat])
                }
            } else {
                textureCords.append(contentsOf: result.1)
                for _ in 0..<result.0 {
                    vertexCords.append(contentsOf: [xFloat, yFloat + yStep,
                                                    xFloat + xStep, yFloat + yStep,
                                                    xFloat, yFloat,
                                                    xFloat + xStep, yFloat + yStep,
                                                    xFloat + xStep, yFloat,
                                                    xFloat, yFloat])
                }
            }
            if fillerMaterialCords.count > 0 {
//                var x1ModOptional: Float?
//                var x2ModOptional: Float?
//                var y1ModOptional: Float?
//                var y2ModOptional: Float?
//                switch fillerMaterialType {
//                case .top: y2ModOptional = yStep / 2
//                case .bottom: y1ModOptional = -yStep / 2
//                case .whole: break
//                case .left: x2ModOptional = -xStep / 2
//                case .right: x1ModOptional = xStep / 2
//                default:
//                    break
//                }
//                var x1Mod: Float = 0
//                if x1ModOptional != nil {
//                    x1Mod = x1ModOptional!
//                }
//                var x2Mod: Float = 0
//                if x2ModOptional != nil {
//                    x2Mod = x2ModOptional!
//                }
//                var y1Mod: Float = 0
//                if y1ModOptional != nil {
//                    y1Mod = y1ModOptional!
//                }
//                var y2Mod: Float = 0
//                if y2ModOptional != nil {
//                    y2Mod = y2ModOptional!
//                }
//                vertexCords.append(contentsOf: [xFloat + x1Mod, yFloat + yStep + y1Mod,
//                                                xFloat + xStep + x2Mod, yFloat + yStep + y1Mod,
//                                                xFloat + x1Mod, yFloat + y2Mod,
//                                                xFloat + xStep + x2Mod, yFloat + yStep + y1Mod,
//                                                xFloat + xStep + x2Mod, yFloat + y2Mod,
//                                                xFloat + x1Mod, yFloat + y2Mod])
            }
            

        }

        self.vertexCords = vertexCords
        self.textureCords = textureCords
        updateBuffers()
        setupMapTexture()
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

        for sortedCorner in sortedUniqueCorners {
            tilesToAdd.append((sortedCorner, getGraphicsTypeForCorners(targetType: sortedCorner, corners: corners)))
        }
        
        for tileToAdd in tilesToAdd {
            let cordinate = TileHelper.getTileForDirection(tile: tileToAdd.0, graphicType: tileToAdd.1)
            textureCords.append(contentsOf: getTextureCordsForCell(x: cordinate.x, y: cordinate.y))
        }
        return (tilesToAdd.count, textureCords)
    }
    
    // Get Filler Material Texture Cords
    private func getFillerMaterialTextureCords(corners: [TileType], filler: TileType) -> ([Float], TileGraphicFillerType?) {
        var accountedTypes: [TileType] = []
        for corner in corners {if !accountedTypes.contains(corner) {accountedTypes.append(corner)}}
        // 4 different Corners
        if accountedTypes.count == 4 {return (TileHelper.getTextureCordsForFillerType(fillerType: .whole, tileType: filler, textureMapWidth: terrainTileTexture.width, textureMapHeight: terrainTileTexture.height), .whole)}
        
        // Diagonal
        if corners[0] == corners[3] || corners[1] == corners[2] {
            return ([], nil)
        }
        
        for (index, cellType) in corners.enumerated() {
            var forwardIndex = index + 1
            if forwardIndex == corners.count {
                forwardIndex = 0
            }
            if cellType == corners[forwardIndex] && index == 0 { // Top
                return (TileHelper.getTextureCordsForFillerType(fillerType: .top, tileType: filler, textureMapWidth: terrainTileTexture.width, textureMapHeight: terrainTileTexture.height), .top)
            } else if index == 2 && cellType == corners[forwardIndex] { // Bottom
                return (TileHelper.getTextureCordsForFillerType(fillerType: .bottom, tileType: filler, textureMapWidth: terrainTileTexture.width, textureMapHeight: terrainTileTexture.height), .bottom)
            } else if index == 1 && cellType == corners[3] { // Left
                return (TileHelper.getTextureCordsForFillerType(fillerType: .left, tileType: filler, textureMapWidth: terrainTileTexture.width, textureMapHeight: terrainTileTexture.height), .left)
            } else if index == 0 && cellType == corners[2] { // Right
                return (TileHelper.getTextureCordsForFillerType(fillerType: .right, tileType: filler, textureMapWidth: terrainTileTexture.width, textureMapHeight: terrainTileTexture.height), .right)
            }
        }
        return ([], nil)
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
//        return .whole
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

        let tileSetWidth = imageRef.width
        let tilSetHeight = imageRef.height

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: tileSetWidth, height: tilSetHeight, mipmapped: false)
        textureDescriptor.usage = [.shaderRead]
        
        let region = MTLRegionMake2D(0, 0, tileSetWidth, tilSetHeight)

        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let texture = GraphicsDevice.Device.makeTexture(descriptor: textureDescriptor)!
        texture.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: tileSetWidth * 4)
        terrainTileTexture = texture
    }
    
    // Setup Map Texture
    private func setupMapTexture() {
        let mapTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: map.width * 16, height: map.height * 16, mipmapped: false)
        mapTextureDescriptor.usage = [.renderTarget, .shaderRead]
        
        mapTexture = GraphicsDevice.Device.makeTexture(descriptor: mapTextureDescriptor)
        
        let commandQueue = GraphicsDevice.Device.makeCommandQueue()!
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = mapTexture
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        let pipeLineState = RenderPipelineStateLibrary.shared.pipelineState(.Map)
        
        renderEncoder.setRenderPipelineState(pipeLineState)
        
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
        
        var width = map.width * 16
        var height = map.height * 16
        
        var transform = (Float(0), Float(0))
        var scale     = Float(1)
//        var width     = touchController.width
//        var height    = touchController.height
        var gridSize  = cellSize
        
        renderEncoder.setVertexBuffer(vertexPosBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(texturePosBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBytes(&transform, length: 8, index: 2)
        renderEncoder.setVertexBytes(&scale, length: 4, index: 3)
        renderEncoder.setVertexBytes(&width, length: 4, index: 4)
        renderEncoder.setVertexBytes(&height, length: 4, index: 5)
        renderEncoder.setVertexBytes(&gridSize, length: 4, index: 6)
        renderEncoder.setFragmentTexture(terrainTileTexture, index: 0)
        renderEncoder.setFragmentSamplerState(sampler, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCords.count / 2)
        
        renderEncoder.endEncoding()
        commandBuffer.commit()
    }
    
    // Update Buffers
    private func updateBuffers() {
        vertexPosBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertexCords, length: vertexCords.count * 4, options: [])
        texturePosBuffer = GraphicsDevice.Device.makeBuffer(bytes: textureCords, length: textureCords.count * 4, options: [])
    }
}
