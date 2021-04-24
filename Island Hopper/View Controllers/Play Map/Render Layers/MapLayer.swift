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
        samplerDescriptor.minFilter             = MTLSamplerMinMagFilter.linear
        samplerDescriptor.magFilter             = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.maxAnisotropy         = 1
        samplerDescriptor.borderColor = .opaqueWhite
        samplerDescriptor.sAddressMode          = MTLSamplerAddressMode.clampToEdge
        samplerDescriptor.tAddressMode          = MTLSamplerAddressMode.clampToEdge
        samplerDescriptor.rAddressMode          = MTLSamplerAddressMode.clampToEdge
//        samplerDescriptor.compareFunction = .
//        samplerDescriptor.filter
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
        
        
//        vertexCords.append(contentsOf: [-1, 1, 1, 1, -1, -1, 1, 1, 1, -1, -1, -1])
        
//        vertexCords.append(contentsOf: [-1, 1, 0, 1, -1, -1, 0, 1, 0, -1, -1, -1])
//        vertexCords.append(contentsOf: [0, 1, 1, 1, 0, -1, 1, 1, 1, -1, 0, -1])
//
//        textureCords.append(contentsOf: getTextureCordsForCell(x: 0, y: 0))
//        textureCords.append(contentsOf: getTextureCordsForCell(x: 1, y: 0))
        
        //            let layerColor = getColorForType(mapLevel)
        for index in 0..<(map.width - 1) * (map.height - 1) {

            let y = index / (map.width)
            let x = index % (map.width)
            let yFloat = Float(y)
            let xFloat = Float(x)

            let result = getTextureCordsAndVerticesCountForCorners(corners: [map.tiles[index + y],
                                                                             map.tiles[index + y + 1],
                                                                             map.tiles[index + y + map.width],
                                                                             map.tiles[index + y + map.width + 1]])
            
            textureCords.append(contentsOf: result.1)
            for _ in 0..<result.0 {
                vertexCords.append(contentsOf: [xFloat, yFloat + 1,
                                                xFloat + 1, yFloat + 1,
                                                xFloat, yFloat,
                                                xFloat + 1, yFloat + 1,
                                                xFloat + 1, yFloat,
                                                xFloat, yFloat])
            }

            
            // Get Type
//            var config: Int8 = 0
//
//            var materials: [TileType] = []
//            if !materials.contains(map.tiles[index + y]) {
//                materials.append(map.tiles[index + y])
//            }
//            if !materials.contains(map.tiles[index + y + 1]) {
//                materials.append(map.tiles[index + y + 1])
//            }
//            if !materials.contains(map.tiles[index + y + map.width + 1]) {
//                materials.append(map.tiles[index + y + map.width + 1])
//            }
//            if !materials.contains(map.tiles[index + y + map.width + 2]) {
//                materials.append(map.tiles[index + y + map.width + 2])
//            }
            
//            if map.tiles[index + y] == mapLevel { // Bottom Left
//                config += 2
//            }
//            if map.tiles[index + 1 + y] == mapLevel { // Bottom Right
//                config += 1
//            }
//            if map.tiles[index + map.width + y + 1] == mapLevel { // Top Left
//                config += 8
//            }
//            if map.tiles[index + map.width + y + 2] == mapLevel { // Top Right
//                config += 4
//            }
//            if materials.count > 2 {
//                var lowestLevel = TileType.allCases.last!
//                var highestLevel = TileType.allCases.first!
//                for material in materials {
//                    if material.rawValue < lowestLevel.rawValue {
//                        lowestLevel = material
//                    }
//                    if material.rawValue > highestLevel.rawValue {
//                        highestLevel = material
//                    }
//                }
//                var middleLevel: TileType = highestLevel
//                for material in materials {
//                    if material != lowestLevel && material != highestLevel && material.rawValue < middleLevel.rawValue {
//                        middleLevel = material
//                    }
//                }
//                if mapLevel == middleLevel {
//                    let filler = getFillerForMultipleMaterials(fill: mapLevel,
//                                                               corners: [map.tiles[index + chunkSize + y + 1],
//                                                                         map.tiles[index + chunkSize + y + 2],
//                                                                         map.tiles[index + 1 + y],
//                                                                         map.tiles[index + y]],
//                                                               chunk: address.chunk,
//                                                               index: index,
//                                                               layerColor: layerColor)
//                    chunkVertices.append(contentsOf: filler.0)
//                    chunkColors.append(contentsOf: filler.1)
//                }
//            }
//            let vertexAndColors = getVertexAndColorsForConfig(config, index: index, chunk: address.chunk, color: layerColor)
//
//            chunkVertices.append(contentsOf: vertexAndColors.0)
//            chunkColors.append(contentsOf: vertexAndColors.1)
        }

//        var vertexStartIndex: Int = 0
//        var colorStartIndex: Int = 0
//
//        for chunk in chunks {
//            if chunk.value.index < chunks[chunkCordinate]!.index {
//                vertexStartIndex += chunk.value.vertexCount
//                colorStartIndex += chunk.value.colorCount
//            }
//        }
//
//        vertices.replaceSubrange(vertexStartIndex..<vertexStartIndex + address.vertexCount, with: chunkVertices)
//        colors.replaceSubrange(colorStartIndex..<colorStartIndex + address.colorCount, with: chunkColors)
//
//        chunks[chunkCordinate]!.vertexCount = chunkVertices.count
//        chunks[chunkCordinate]!.colorCount = chunkColors.count
        self.vertexCords = vertexCords
        self.textureCords = textureCords
        updateBuffers()
    }
    
    // Get Config For Multiple Materials
//    func getFillerForMultipleMaterials(fill:        TileType,
//                                       corners:     [TileType],
//                                       chunk:       IntCordinate,
//                                       index:       Int,
//                                       layerColor:  UIColor) -> ([Float], [Float]) {
//
//        let x = Float(index % chunkSize + chunkSize * chunk.x)
//        let y = Float(index / chunkSize + chunkSize * chunk.y)
//
//        let tmx = x + 0.5 // Top M
//        let tmy = y + 1
//        let mlx = x // Middle L
//        let mly = y + 0.5
//        let mrx = x + 1 // Middle R
//        let mry = y + 0.5
//        let bmx = x + 0.5 // Bottom Middle
//        let bmy = y + 0
//
//        // Top Left And Right
//        if corners[0] == corners[2] {
//            return ([], [])
//        } else if corners[1] == corners[3] {
//            return ([], [])
//        }
//        // Whole Empty
//        var accountedTypes: [TileType] = []
//        for cellType in corners {
//            if !accountedTypes.contains(cellType) {
//                accountedTypes.append(cellType)
//            }
//        }
//        if accountedTypes.count == 4 {
//            let vertices: [Float] = [tmx, tmy,
//                                     mrx, mry,
//                                     bmx, bmy,
//                                     tmx, tmy,
//                                     bmx, bmy,
//                                     mlx, mly]
//            var colors: [Float] = []
//
//            for _ in 0..<vertices.count / 2 {
//                colors.append(contentsOf: [Float(layerColor.redValue),
//                                           Float(layerColor.greenValue),
//                                           Float(layerColor.blueValue)])
//            }
//            return (vertices,
//                    colors)
//        }
//        var vertices: [Float] = []
//        var colors: [Float] = []
//        for (index, cellType) in corners.enumerated() {
//            var forwardIndex = index + 1
//            if forwardIndex == corners.count {
//                forwardIndex = 0
//            }
//            if cellType == corners[forwardIndex] && index == 0 {
//                vertices.append(contentsOf: [mlx, mly, mrx, mry, bmx, bmy])
//            } else if cellType == corners[forwardIndex] && index == 1 {
//                vertices.append(contentsOf: [tmx, tmy, bmx, bmy, mlx, mly])
//            } else if cellType == corners[forwardIndex] && index == 2 {
//                vertices.append(contentsOf: [tmx, tmy, mrx, mry, mlx, mly])
//            } else if cellType == corners[forwardIndex] && index == 3 {
//                vertices.append(contentsOf: [tmx, tmy, mrx, mry, bmx, bmy])
//            }
//        }
//
//        for _ in 0..<vertices.count / 2 {
//            colors.append(contentsOf: [Float(layerColor.redValue),
//                                       Float(layerColor.greenValue),
//                                       Float(layerColor.blueValue)])
//        }
//        return (vertices,
//                colors)
//    }
    
    // Get Vertex And Colors For Config
//    func getVertexAndColorsForConfig(_ config: Int8, index: Int, chunk: IntCordinate, color: UIColor) -> ([Float],[Float]) {
//
//        let x = Float(index % chunkSize + chunkSize * chunk.x)
//        let y = Float(index / chunkSize + chunkSize * chunk.y)
//
//        let tlx = x // Top L
//        let tly = y + 1
//        let tmx = x + 0.5 // Top M
//        let tmy = y + 1
//        let trx = x + 1 // Top R
//        let trY = y + 1
//
//        let mlx = x // Middle L
//        let mly = y + 0.5
//        let mrx = x + 1
//        let mry = y + 0.5
//
//        let blx = x
//        let bly = y + 0
//        let bmx = x + 0.5
//        let bmy = y + 0
//        let brx = x + 1
//        let bry = y + 0
//
//        var vertexs: [Float] = []
//        var colors: [Float] = []
//        switch config {
//        case 1:  vertexs = [bmx, bmy, mrx, mry, brx, bry]
//        case 2:  vertexs = [mlx, mly, bmx, bmy, blx, bly]
//        case 3:  vertexs = [mlx, mly, brx, bry, blx, bly, mlx, mly, mrx, mry, brx, bry]
//        case 4:  vertexs = [tmx, tmy, trx, trY, mrx, mry]
//        case 5:  vertexs = [tmx, tmy, trx, trY, bmx, bmy, trx, trY, brx, bry, bmx, bmy]
//        case 6:  vertexs = [tmx, tmy, trx, trY, mlx, mly, trx, trY, blx, bly, mlx, mly, trx, trY, bmx, bmy, blx, bly, trx, trY, mrx, mry, bmx, bmy]
//        case 7:  vertexs = [tmx, tmy, blx, bly, mlx, mly, tmx, tmy, brx, bry, blx, bly, tmx, tmy, trx, trY, brx, bry]
//        case 8:  vertexs = [tlx, tly, tmx, tmy, mlx, mly]
//        case 9:  vertexs = [tlx, tly, bmx, bmy, mlx, mly, tlx, tly, brx, bry, bmx, bmy, tlx, tly, mrx, mry, brx, bry, tlx, tly, tmx, tmy, mrx, mry]
//        case 10: vertexs = [tlx, tly, tmx, tmy, bmx, bmy, tlx, tly, bmx, bmy, blx, bly]
//        case 11: vertexs = [tlx, tly, tmx, tmy, blx, bly, tmx, tmy, brx, bry, blx, bly, tmx, tmy, mrx, mry, brx, bry]
//        case 12: vertexs = [tlx, tly, mrx, mry, mlx, mly, tlx, tly, trx, trY, mrx, mry]
//        case 13: vertexs = [tlx, tly, bmx, bmy, mlx, mly, tlx, tly, trx, trY, bmx, bmy, trx, trY, brx, bry, bmx, bmy]
//        case 14: vertexs = [tlx, tly, bmx, bmy, blx, bly, tlx, tly, trx, trY, bmx, bmy, trx, trY, mrx, mry, bmx, bmy]
//        case 15: vertexs = [tlx, tly, brx, bry, blx, bly, tlx, tly, trx, trY, brx, bry]
//        default: break
//        }
//
//        for _ in 0..<vertexs.count / 2 {
//            colors.append(contentsOf: [Float(color.redValue),
//                                       Float(color.greenValue),
//                                       Float(color.blueValue)])
//        }
//
//        return (vertexs, colors)
//    }
    
    // Get Texture Cords For Cell
    private func getTextureCordsForCell(x: Int, y: Int) -> [Float] {
        let xStep = 16 / Float(terrainTileTexture.width)
        let yStep = 16 / Float(terrainTileTexture.height)
        
//        let xStep: Float = 16
//        let yStep: Float = 16
        
        var adjustedX = xStep * Float(x)
        var adjustedY = yStep * Float(y)
        
//        let adjustedX = xStep * x
//        let adjustedY = yStep * y
        
        var x1 = adjustedX + xStep
        var y1 = adjustedY + yStep
        
//        x1 -= xStep / 16 * 0.01
//        y1 -= yStep / 16 * 0.01
//
//        adjustedX += xStep / 16 * 0.01
//        adjustedY += yStep / 16 * 0.01
        
        x1 -= xStep / 16 * 0
        y1 -= yStep / 16 * 0
        
        adjustedX += xStep / 16 * 0
        adjustedY += yStep / 16 * 0
        
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
            if left.rawValue > right.rawValue {
                return true
            } else {
                return false
            }
        }
        
        let baseLayer = cornersSorted[0]
        
        var sortedUniqueCorners: [TileType] = []
        
        for corner in cornersSorted {
            if !sortedUniqueCorners.contains(corner) {
                sortedUniqueCorners.append(corner)
            }
        }
        
//        if totalUniqueCorners.count == 1 {
//            tilesToAdd.append((corners[0], .whole))
//        } else {
//            tilesToAdd.append((baseLayer, .whole))
//
//        }
        for (index, sortedCorner) in sortedUniqueCorners.enumerated() {
            if index == 0 {
                tilesToAdd.append((sortedCorner, .whole))
                continue
            }
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
        
//        let tileSize = GraphicsDevice.Device.sparseTileSize(with: .type2D, pixelFormat: .bgra8Unorm_srgb, sampleCount: 1)
//
//        var pixelRegion = MTLRegionMake2D(0, 0, 16, 16)
//        var tileRegion: MTLRegion = MTLRegion()
//
//        GraphicsDevice.Device.convertSparsePixelRegions!(&pixelRegion, toTileRegions: &tileRegion, withTileSize: tileSize, alignmentMode: .outward, numRegions: 1)
        
        
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
