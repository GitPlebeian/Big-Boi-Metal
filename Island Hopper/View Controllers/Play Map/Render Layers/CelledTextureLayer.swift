//
//  CelledTextureLayer.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/5/21.
//

import UIKit
import Metal

class Entity {
    var position: IntCordinate
    var textureCords: [Float]
    var width: Int // In Pixels
    var height: Int // In Pixels
    
    init(position: IntCordinate = IntCordinate(),
         textureCords: [Float],
         width: Int,
         height: Int) {
        
        self.position = position
        self.textureCords = textureCords
        self.width = width
        self.height = height
    }
}

class CelledTextureLayer: RenderLayer {

    // MARK: Properties

    weak var touchController: EngineTouchController!
    weak var map: MapLayer!

    var entities: [Entity] = []
    
    var tileTexure: MTLTexture!
    
    // MARK: Init
    
    init(map: MapLayer,
         touchController: EngineTouchController) {
        self.map = map
        self.touchController = touchController
        super.init()
    }
    
    // MARK: Rendering

    override func setPipelineState() {
        self.pipelineState = RenderPipelineStateLibrary.shared.pipelineState(.CelledTexture)
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        
        if entities.count == 0 {
            return
        }
        
        encoder.setRenderPipelineState(pipelineState)

        var transform = touchController.vertexTransform
        var scale     = touchController.vertexScale
        var width     = touchController.width
        var height    = touchController.height
        var gridSize  = map.cellSize

        var positions: [Float] = []
        var textureCords: [Float] = []
        var widthHeight: [Float] = []
        for entity in entities {
            if entity.textureCords.count != 2 {
                fatalError("Entity Texture Cords.count != 2")
            }
            positions.append(Float(entity.position.x))
            positions.append(Float(entity.position.y))
            textureCords.append(contentsOf: entity.textureCords)
            widthHeight.append(Float(entity.width))
            widthHeight.append(Float(entity.height))
        }
        
        let positionsBuffer = GraphicsDevice.Device.makeBuffer(bytes: &positions, length: positions.count * 4, options: [])
        let textureCordsBuffer = GraphicsDevice.Device.makeBuffer(bytes: &textureCords, length: textureCords.count * 4, options: [])
        let widthHeightBuffer = GraphicsDevice.Device.makeBuffer(bytes: &widthHeight, length: widthHeight.count * 4, options: [])

        encoder.setVertexBuffer(positionsBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(textureCordsBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(widthHeightBuffer, offset: 0, index: 2)
        encoder.setVertexBytes(&transform, length: 8, index: 3)
        encoder.setVertexBytes(&scale, length: 4, index: 4)
        encoder.setVertexBytes(&width, length: 4, index: 5)
        encoder.setVertexBytes(&height, length: 4, index: 6)
        encoder.setVertexBytes(&gridSize, length: 4, index: 7)
        encoder.setFragmentTexture(tileTexure, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: positions.count * 3)
    }
    
    // MARK: Public
    
    // Add Entitiy
    func addEntity(entity: Entity) {
        entities.append(entity)
    }
    
    // Remove Entity
    func removeEntity(entity: Entity) {
        for (index, e) in entities.enumerated() {
            if entity === e {
                entities.remove(at: index)
                return
            }
        }
    }

    // MARK: Helpers

}
