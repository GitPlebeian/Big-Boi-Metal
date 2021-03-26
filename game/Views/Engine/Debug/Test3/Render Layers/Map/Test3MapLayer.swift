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
    case darkSea = 0
    case superDeepWater = 1
    case deepWater = 2
    case water = 3
    case shallowWater = 4
    case beach = 5
    case grass = 6
    case forest = 7
    case mountain1 = 8
    case mountain2 = 9
    case mountain3 = 10
    case mountain4 = 11
    case snow = 12
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
}

enum CellGraphicType: UInt8 {
    case whole = 0
    
    case other = 255
}

struct ChunkAddress {
    var chunk: IntCordinate
    var index: Int
    var types: [CellType] = []
    var neighbors: [IntCordinate : ChunkAddress] = [:]
    var vertexCount: Int = 0
    var colorCount: Int = 0
    var type: ChunkType = .normal
    var valueOffset: Float = 0
    
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
    
    let chunkSize:   Int   = 48
    let cellSize:    Float = 44
    var fadeInset:   Int = 0
    var fadeLength:  Int = 0
    
    var cells: [Float] = []
    var colors: [Float] = []
    var vertexs: [Float] = []
    var newColors: [Float] = []
    
    var chunks: [IntCordinate : ChunkAddress] = [:]
    var selectedChunks: [IntCordinate] = []
    
    var vertexBuffer: MTLBuffer!
    var colorBuffer: MTLBuffer!
    
    // Perlin
    var noiseSource: GKNoiseSource
    var frequency:   Double = 1
    var octaveCount: Int = 8
    var persistence: Double = 0.52
    var lacunarity:  Double = 1.89
    var seed: Int32 = 0
    
    // Debug Stuff
    
    // MARK: Init
    
    override init() {
        let noiseSource = GKPerlinNoiseSource(frequency: frequency,
                                              octaveCount: octaveCount,
                                              persistence: persistence,
                                              lacunarity: lacunarity,
                                              seed: seed)
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
            
            var transform = controller.view.vertexTransform
            var scale     = controller.view.vertexScale
            var width     = controller.view.width
            var height    = controller.view.height
            var gridSize  = self.cellSize
            
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
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
                                              seed: seed)
        self.noiseSource = noiseSource
    }
    
    // Add Chunk
    func addChunk(_ chunk: IntCordinate) {
        
        if chunks[chunk] != nil {
            if let indexOfChunk = selectedChunks.firstIndex(of: chunk) {
                selectedChunks.remove(at: indexOfChunk)
                tintChunkColors(color: UIColor.white, strength: 0.12, cordinate: chunk)
            } else {
                selectedChunks.append(chunk)
                tintChunkColors(color: UIColor.white, strength: -0.12, cordinate: chunk)
            }
        } else {
            let chunkAddress = ChunkAddress(chunk: chunk, index: chunks.count)
            
            chunks[chunk] = chunkAddress
            
            updateChunksForNewChunk(chunkAddress)
        }
        updateMapBuffer()
        
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
    
    // Update Selected Chunks For Config
    func updateSelectedChunksForConfig(_ config: ChunkType) {
        for selectedChunk in selectedChunks {
            chunks[selectedChunk]!.type = config
        }
        updateChunks(selectedChunks)
        for selectedChunk in selectedChunks {
            tintChunkColors(color: UIColor.white, strength: -0.12, cordinate: selectedChunk)
        }
        updateMapBuffer()
    }
    
    // Clear Selected Chunks
    func clearSelectedChunks() {
        for selectedChunk in selectedChunks {
            tintChunkColors(color: UIColor.white, strength: 0.12, cordinate: selectedChunk)
        }
        selectedChunks = []
        updateMapBuffer()
    }
    
    // Clear Chunks
    func clearChunks() {
        cells = []
        colors = []
        chunks.removeAll()
        updateMapBuffer()
    }
    
    // Reload Map
    func reloadMap() {
            
        var toUpdate: [IntCordinate] = []
        for address in chunks {
            updateChunksForNeighbor(address.value)
            toUpdate.append(address.value.chunk)
        }
        updateCellGraphics(toUpdate)
        updateMapBuffer()
    }
    
    // Get Type For Cell
    func getTypeForCell(chunkCordinate: IntCordinate, cell: Cell) -> CellType? {
        guard let chunk = chunks[chunkCordinate] else {return nil}
        let cellX = cell.x % chunkSize
        let cellY = cell.y % chunkSize
        return chunk.types[chunkSize * cellY + cellX]
    }
    
    // MARK: Helpers
    
    // Update Map Buffers
    private func updateMapBuffer() {
        if vertexs.count == 0 {
            return
        }
        vertexBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertexs, length: vertexs.count * 4, options: [])
        colorBuffer = GraphicsDevice.Device.makeBuffer(bytes: newColors, length: newColors.count * 4, options: [])
    }
    
    // Update Chunks
    private func updateChunks(_ chunks: [IntCordinate]) {
        for chunk in chunks {
            let types = getChunkData(self.chunks[chunk]!)
            self.chunks[chunk]!.types = types
        }
        updateCellGraphics(chunks)
        updateMapBuffer()
    }
    
    // Update Chunks For New Chunk
    private func updateChunksForNewChunk(_ newChunk: ChunkAddress) {
        
        var chunksNeededUpdates: [IntCordinate] = []
        
//        var x = -1
//        var y = 1
//        for _ in 0..<8 {
//            let cordinate = IntCordinate(newChunk.chunk.x + x, newChunk.chunk.y + y)
//            if chunks[cordinate] != nil {
//                chunks[newChunk.chunk]!.neighbors[cordinate] = chunks[cordinate]!
//                chunks[cordinate]!.neighbors[newChunk.chunk] = newChunk
//                updateChunksForNeighbor(chunks[cordinate]!)
//                chunksNeededUpdates.append(cordinate)
//            }
//
//            x += 1
//            if y == 0 && x == 0 {
//                x += 1
//            }
//            if x == 2 {
//                x = -1
//                y -= 1
//            }
//        }
        
        let types = self.getChunkData(chunks[newChunk.chunk]!)
        chunks[newChunk.chunk]!.types = types
        chunksNeededUpdates.append(newChunk.chunk)
        
        // Update Other Graphics
        updateCellGraphics(chunksNeededUpdates)
    }
    
    // Update Chunk Directions For New Direction
    
    // Update Chunks For Neighbor
    private func updateChunksForNeighbor(_ chunkAddress: ChunkAddress) {
        let types = self.getChunkData(chunkAddress)
        chunks[chunkAddress.chunk]!.types = types
    }
}
