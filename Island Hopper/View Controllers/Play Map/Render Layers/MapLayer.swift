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
    var terrainTileTexture: MTLTexture! {
        didSet {
            setupVertexTextureData()
        }
    }
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

        self.vertexCords = vertexCords
        self.textureCords = textureCords
        updateBuffers()
        setupMapTexture()
    }
    
    // Get Texture Cords For Cell
    private func getTextureCordsForCell(x: Int, y: Int) -> [Float] {
//        let xStep = 16 / Float(terrainTileTexture.width)
//        let yStep = 16 / Float(terrainTileTexture.height)
        
        let xStep: Float = 16
        let yStep: Float = 16

        let pixelOffsetX: Float = 0
        let pixelOffsetY: Float = 0
        
        let adjustedX = xStep * Float(x) + pixelOffsetX
        let adjustedY = yStep * Float(y) + pixelOffsetY
        
        let x1 = adjustedX + xStep - pixelOffsetX
        let y1 = adjustedY + yStep - pixelOffsetY
        
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
    
    // Get Graphics Type For Corners
    private func getGraphicsTypeForCorners(targetType: TileType, corners: [TileType]) -> TileGraphicType {
        
        var config: Int = 0
        
        for (index, corner) in corners.enumerated() {
            if corner != targetType && corner.rawValue < targetType.rawValue {
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
        samplerDescriptor.normalizedCoordinates = false
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
