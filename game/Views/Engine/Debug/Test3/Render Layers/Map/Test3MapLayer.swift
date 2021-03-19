//
//  Test3MapLayer.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import UIKit
import Metal
import GameKit

enum CellType: UInt8, CaseIterable {
    case superDeepWater = 0
    case deepWater = 1
    case water = 2
    case shallowWater = 3
    case beach = 4
    case grass = 5
    case forest = 6
    case mountain1 = 7
    case mountain2 = 8
    case mountain3 = 9
    case mountain4 = 10
    case snow = 11
}

enum ChunkType: Int, CaseIterable {
    case normal = 0
    case fadeNorth = 1
    case fadeNorthEast = 2
    case fadeNorthEastBig = 3
    case fadeEast = 4
    case fadeSouthEast = 5
    case fadeSouthEastBig = 6
    case fadeSouth = 7
    case fadeSouthWest = 8
    case fadeSouthWestBig = 9
    case fadeWest = 10
    case fadeNorthWest = 11
    case fadeNorthWestBig = 12
    case ignoreNeighbors = 13
}

enum CellGraphicType: UInt8 {
    case whole = 0
    
    case other = 255
}

struct ChunkData {
    var cells:  [Float] = []
    var colors: [Float] = []
    var types: [CellType] = []
}

struct ChunkAddress {
    var chunk: IntCordinate
    var index: Int
    var types: [CellType] = []
    var neighbors: [IntCordinate : ChunkAddress] = [:]
    var vertexCount: Int = 0
    var colorCount: Int = 0
    var type: ChunkType = .normal
    
    // Has Neighbor
    func hasNeighbor(_ direction: Direction) -> Bool {
        switch direction {
        case .north:     return neighbors[IntCordinate(chunk.x, chunk.y + 1)]     != nil
        case .east:      return neighbors[IntCordinate(chunk.x + 1, chunk.y)]     != nil
        case .south:     return neighbors[IntCordinate(chunk.x, chunk.y - 1)]     != nil
        case .west:      return neighbors[IntCordinate(chunk.x - 1, chunk.y)]     != nil
        case .northEast: return neighbors[IntCordinate(chunk.x + 1, chunk.y + 1)] != nil
        case .southEast: return neighbors[IntCordinate(chunk.x + 1, chunk.y - 1)] != nil
        case .southWest: return neighbors[IntCordinate(chunk.x - 1, chunk.y - 1)] != nil
        case .northWest: return neighbors[IntCordinate(chunk.x - 1, chunk.y + 1)] != nil
        }
    }
}

struct Cell {
    var x: Int
    var y: Int
}

class Test3MapLayer: Test3RenderLayer {
    
    // MARK: Properties
    
    weak var controller: Test3GameController?
    
    let chunkSize:   Int   = 32
    let cellSize:    Float = 44
    var fadeInset:   Int = 0
    var fadeLength:  Int = 14
    
    var cells: [Float] = []
    var colors: [Float] = []
    var vertexs: [Float] = []
    var newColors: [Float] = []
    
    var chunks: [IntCordinate : ChunkAddress] = [:]
    
    // Perlin
    var noiseSource: GKNoiseSource
    var frequency:   Double = 1
    var octaveCount: Int = 6
    var persistence: Double = 0.52
    var lacunarity:  Double = 1.92
    
    // Debug Stuff
    
    // MARK: Init
    
    override init() {
        let noiseSource = GKPerlinNoiseSource(frequency: frequency,
                                              octaveCount: octaveCount,
                                              persistence: persistence,
                                              lacunarity: lacunarity,
                                              seed: 1)
        self.noiseSource = noiseSource
        super.init()
    }
    
    // MARK: Deinit
    
    deinit {
        print("Test3Map Layer Deinit")
    }
    
    // MARK: Rendering
    
    override func setPipelineState() {
        self.pipelineState = Test3RenderPipelineStateLibrary.shared.pipelineState(.MapMarchingSquares)
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        
        
        guard let controller = controller else {return}
        
        if vertexs.count != 0 {
            // Render Marching Squares Map
            
            encoder.setRenderPipelineState(pipelineState)
            
            let vertexBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertexs, length: vertexs.count * 4, options: [])
            let newColorBuffer = GraphicsDevice.Device.makeBuffer(bytes: newColors, length: newColors.count * 4, options: [])
            
            var transform = controller.view.vertexTransform
            var scale     = controller.view.vertexScale
            var width     = controller.view.width
            var height    = controller.view.height
            var gridSize  = self.cellSize
            
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(newColorBuffer, offset: 0, index: 1)
            encoder.setVertexBytes(&transform, length: 8, index: 2)
            encoder.setVertexBytes(&scale, length: 4, index: 3)
            encoder.setVertexBytes(&width, length: 4, index: 4)
            encoder.setVertexBytes(&height, length: 4, index: 5)
            encoder.setVertexBytes(&gridSize, length: 4, index: 6)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexs.count / 2)
        }
    }
    
    // MARK: Public
    
    // Update Noise Source
    func updateNoiseSource() {
        let noiseSource = GKPerlinNoiseSource(frequency: frequency,
                                              octaveCount: octaveCount,
                                              persistence: persistence,
                                              lacunarity: lacunarity,
                                              seed: 1)
        self.noiseSource = noiseSource
    }
    
    // Add Chunk
    func addChunk(_ chunk: IntCordinate) {
        
        if chunks[chunk] != nil {
            // Increment The Chunk Type
            if (chunks[chunk]!.type.rawValue + 1) >= ChunkType.allCases.count {
                chunks[chunk]!.type = .normal
            } else {
                chunks[chunk]!.type = ChunkType.init(rawValue: chunks[chunk]!.type.rawValue + 1)!
            }
            updateChunksForNewChunk(chunks[chunk]!)
        } else {
            let chunkAddress = ChunkAddress(chunk: chunk, index: chunks.count)
            
            chunks[chunk] = chunkAddress
            
            updateChunksForNewChunk(chunkAddress)
        }

        
        let afterChunksCount = Float(chunks.count)
        let afterVertexCount = Float(vertexs.count)
        let afterVertexSizeKB = Float(vertexs.count * 4) / 1024
        let afterVertexSizeMB = Float(vertexs.count * 4) / 1024 / 1024
        let afterColorsSizeKB = Float(newColors.count * 4) / 1024
        let afterColorsSizeMB = Float(newColors.count * 4) / 1024 / 1024
        
        print("""
\n\nTotal Chunks:        \(afterChunksCount)
Chunk / Vertex Ratio:    \(afterVertexCount / afterChunksCount)
Chunk / Vertex Ratio KB: \(afterVertexSizeKB / afterChunksCount)
Chunk / Vertex Ratio MB: \(afterVertexSizeMB / afterChunksCount)
Chunk / Color  Ratio KB: \(afterColorsSizeKB / afterChunksCount)
Chunk / Color  Ratio MB: \(afterColorsSizeMB / afterChunksCount)
Chunk Vertex Count:      \(vertexs.count)
Chunk Triangle Count:    \(vertexs.count / 6)
Chunk Vertex Size KB:    \(afterVertexSizeKB)
Chunk Vertex Size MB:    \(afterVertexSizeMB)
Chunk Color Size MB:     \(afterColorsSizeMB)
""")
    }
    
    // Clear Chunks
    func clearChunks() {
        cells = []
        colors = []
        chunks.removeAll()
    }
    
    // Reload Map
    func reloadMap() {
            
        var toUpdate: [IntCordinate] = []
        for address in chunks {
            updateChunksForNeighbor(address.value)
            toUpdate.append(address.value.chunk)
        }
        updateCellGraphics(toUpdate)
    }
    
    // Get Type For Cell
    func getTypeForCell(chunkCordinate: IntCordinate, cell: Cell) -> CellType? {
        guard let chunk = chunks[chunkCordinate] else {return nil}
        let cellX = cell.x % chunkSize
        let cellY = cell.y % chunkSize
        print("\nCellX: \(cellX) | CellY: \(cellY)")
        return chunk.types[chunkSize * cellY + cellX]
    }
    
    // MARK: Helpers
    
    // Update Chunks For New Chunk
    private func updateChunksForNewChunk(_ newChunk: ChunkAddress) {
        
        var chunksNeededUpdates: [IntCordinate] = []
        
        var x = -1
        var y = 1
        for _ in 0..<8 {
            let cordinate = IntCordinate(newChunk.chunk.x + x, newChunk.chunk.y + y)
            if chunks[cordinate] != nil {
                chunks[newChunk.chunk]!.neighbors[cordinate] = chunks[cordinate]!
                chunks[cordinate]!.neighbors[newChunk.chunk] = newChunk
                updateChunksForNeighbor(chunks[cordinate]!)
                chunksNeededUpdates.append(cordinate)
            }
            
            x += 1
            if y == 0 && x == 0 {
                x += 1
            }
            if x == 2 {
                x = -1
                y -= 1
            }
        }
        
        let chunkData = self.getChunkData(chunks[newChunk.chunk]!)
        chunks[newChunk.chunk]!.types = chunkData.types
        chunksNeededUpdates.append(newChunk.chunk)
        
        // Update Other Graphics
        updateCellGraphics(chunksNeededUpdates)
    }
    
    // Update Chunk Directions For New Direction
    
    // Update Chunks For Neighbor
    private func updateChunksForNeighbor(_ chunkAddress: ChunkAddress) {
        let chunkData = self.getChunkData(chunkAddress)
        chunks[chunkAddress.chunk]!.types = chunkData.types
    }
}
