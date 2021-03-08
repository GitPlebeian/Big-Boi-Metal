//
//  Test3MapLayer.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import UIKit
import Metal
import GameKit

struct ChunkData {
    var cells: [Float] = []
    var colors: [Float] = []
}

struct Chunk {
    var x: Int
    var y: Int
}

struct Cell {
    var x: Int
    var y: Int
}

class Test3MapLayer: Test3RenderLayer {
    
    // MARK: Properties
    
    weak var controller: Test3GameController?
    
    let chunkSize:   Int   = 16
    let cellSize:    Float = 44
    
    var cells: [Float] = []
    var colors: [Float] = []
    
    // Perlin
    var volatility: Double = 6.51
    var noiseSource: GKNoiseSource
    
    // Debug Stuff
    
    // MARK: Init
    
    override init() {
        let noiseSource = GKPerlinNoiseSource()
        noiseSource.seed = 0
        noiseSource.persistence = 0.05
        self.noiseSource = noiseSource
        super.init()
    }
    
    // MARK: Deinit
    
    deinit {
        print("Test3Map Layer Deinit")
    }
    
    // MARK: Rendering
    
    override func setPipelineState() {
        self.pipelineState = Test3RenderPipelineStateLibrary.shared.pipelineState(.Map)
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        
        if cells.count == 0 {return}
        
        guard let controller = controller else {return}
        
        encoder.setRenderPipelineState(pipelineState)
        
        let cellBuffer = GraphicsDevice.Device.makeBuffer(bytes: cells, length: cells.count * 4, options: [])
        let colorBuffer = GraphicsDevice.Device.makeBuffer(bytes: colors, length: colors.count * 4, options: [])
        
        var transform = controller.view.vertexTransform
        var scale     = controller.view.vertexScale
        var width     = controller.view.width
        var height    = controller.view.height
        var gridSize  = self.cellSize
        
        encoder.setVertexBuffer(cellBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&transform, length: 8, index: 2)
        encoder.setVertexBytes(&scale, length: 4, index: 3)
        encoder.setVertexBytes(&width, length: 4, index: 4)
        encoder.setVertexBytes(&height, length: 4, index: 5)
        encoder.setVertexBytes(&gridSize, length: 4, index: 6)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: cells.count * 3)
    }
    
    // MARK: Public
    
    // Add Chunk
    func addChunk(_ chunk: Chunk) {
            
        let chunk = self.getChunkData(chunk)
        self.cells.append(contentsOf: chunk.cells)
        self.colors.append(contentsOf: chunk.colors)
//        Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: (0)..<(7)), repeats: false) { [weak self] (timer) in
//            timer.invalidate()
//            guard let self = self else {return}
//        }
    }
    
    // Clear Chunks
    func clearChunks() {
        cells = []
        colors = []
    }
    
    // MARK: Helpers
    
    // Get Chunk Data
    private func getChunkData(_ chunk: Chunk) -> ChunkData {
        
        let noise = GKNoise(noiseSource)
        noise.move(by: SIMD3<Double>(Double(chunk.x), 0, Double(chunk.y)))
        
        let noiseMap = GKNoiseMap(noise,
                                  size: SIMD2<Double>(arrayLiteral: 1, 1),
                                  origin: SIMD2(arrayLiteral: 0, 0),
                                  sampleCount: SIMD2<Int32>(Int32(Int(chunkSize + 1)), Int32(chunkSize + 1)),
                                  seamless: true)
        
        var chunkData = ChunkData()
        for x in 0..<chunkSize {
            for y in 0..<chunkSize {
                chunkData.cells.append(Float(x + chunk.x * chunkSize))
                chunkData.cells.append(Float(y + chunk.y * chunkSize))
                
                let value = noiseMap.value(at: SIMD2<Int32>(Int32(x), Int32(y)))
                let color = getColorForFloat(number: value)
                
                chunkData.colors.append(contentsOf: [Float(color.redValue),
                                                     Float(color.greenValue),
                                                     Float(color.blueValue)])
            }
        }
        return chunkData
    }
    
    // Get Color For Float
    func getColorForFloat(number: Float) -> UIColor {
        if number <= -0.5 {
            return .mapDeepWater
        } else if number <= -0.25 {
            return .mapWater
        } else if number <= -0.15 {
            return .mapBeach
        } else if number <= 0.1 {
            return .mapGrass
        } else if number <= 0.4 {
            return .mapForest
        } else if number <= 0.65 {
            return .mapDirt
        } else if number <= 0.95 {
            return .mapMountain
        } else if number <= 0.95 {
            return .mapSnow
        } else {
            return .mapSnow
        }
    }
}
