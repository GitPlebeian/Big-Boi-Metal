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
    var cells:  [Float] = []
    var colors: [Float] = []
}

struct ChunkAddress {
    var chunk: IntCordinate
    var index: Int
    var neighbors: [IntCordinate : ChunkAddress] = [:]
    
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
    var fadeLength:  Int = 12
    
    var cells: [Float] = []
    var colors: [Float] = []
    
    var chunks: [IntCordinate : ChunkAddress] = [:]
    
    // Perlin
    var noiseSource: GKNoiseSource
    var frequency:   Double = 1
    var octaveCount: Int = 1
    var persistence: Double = 1
    var lacunarity:  Double = 1
    
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
            return
        }
        
        let chunkAddress = ChunkAddress(chunk: chunk, index: chunks.count)
                
        print("Adding Chunk: \(chunk.x) | \(chunk.y)")
        
        chunks[chunk] = chunkAddress
        
        updateChunksForNewChunk(chunkAddress)
        
        print("Cunks Loaded: \(chunks.count)")
    }
    
    // Clear Chunks
    func clearChunks() {
        cells = []
        colors = []
        chunks.removeAll()
    }
    
    // Reload Map
    func reloadMap() {
        
        for address in chunks {
            updateChunksForNeighbor(address.value)
        }
    }
    
    // MARK: Helpers
    
    // Update Chunks For New Chunk
    private func updateChunksForNewChunk(_ newChunk: ChunkAddress) {
        
        var x = -1
        var y = 1
        for _ in 0..<8 {
            let cordinate = IntCordinate(newChunk.chunk.x + x, newChunk.chunk.y + y)
            if chunks[cordinate] != nil {
                chunks[newChunk.chunk]!.neighbors[cordinate] = chunks[cordinate]!
                chunks[cordinate]!.neighbors[newChunk.chunk] = newChunk
                updateChunksForNeighbor(chunks[cordinate]!)
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
        self.cells.append(contentsOf: chunkData.cells)
        self.colors.append(contentsOf: chunkData.colors)
    }
    
    // Update Chunk Directions For New Direction
    
    // Update Chunks For Neighbor
    private func updateChunksForNeighbor(_ chunkAddress: ChunkAddress) {
        let chunkData = self.getChunkData(chunkAddress)
        colors.replaceSubrange((chunkAddress.index * chunkSize * chunkSize * 3)..<((chunkAddress.index + 1) * chunkSize * chunkSize * 3), with: chunkData.colors)
    }
    
    // Get Chunk Data
    private func getChunkData(_ chunkAddress: ChunkAddress) -> ChunkData {
        
        let chunk = chunkAddress.chunk
        
        let noise = GKNoise(noiseSource)
        
        let modifier: Double = 1
        
        noise.move(by: SIMD3<Double>(Double(chunk.x) * modifier, 0, Double(chunk.y) * modifier))
        
        let noiseMap = GKNoiseMap(noise,
                                  size: SIMD2<Double>(arrayLiteral: 1, 1),
                                  origin: SIMD2(arrayLiteral: 0, 0),
                                  sampleCount: SIMD2<Int32>(Int32(Int(chunkSize + 1)), Int32(chunkSize + 1)),
                                  seamless: true)
        
        let fadeLengthInset = fadeInset + fadeLength
        
        var chunkData = ChunkData()
        for x in 0..<chunkSize {
            for y in 0..<chunkSize {
                chunkData.cells.append(Float(x + chunk.x * chunkSize))
                chunkData.cells.append(Float(y + chunk.y * chunkSize))
                
                var value = noiseMap.value(at: SIMD2<Int32>(Int32(x), Int32(y)))
                
                let inverseX = chunkSize - x
                let inverseY = chunkSize - y
                
                // Top Left Corner
                if x < fadeLengthInset && inverseY < fadeLengthInset {
                    if chunkAddress.hasNeighbor(.west) && chunkAddress.hasNeighbor(.north) && !chunkAddress.hasNeighbor(.northWest) {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        if multiplierX > multiplierY {
                            value += multiplierX
                        } else {
                            value += multiplierY
                        }
                    } else if chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.north) {
                        let multiplier = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.west) && chunkAddress.hasNeighbor(.north) {
                        let multiplier = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.north) {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    }
                }
                // Top Right Corner
                else if inverseX < fadeLengthInset && inverseY < fadeLengthInset {
                    if chunkAddress.hasNeighbor(.north) && chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.northEast) {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        if multiplierX > multiplierY {
                            value += multiplierX
                        } else {
                            value += multiplierY
                        }
                    } else if chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.north) {
                        let multiplier = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.east) && chunkAddress.hasNeighbor(.north) {
                        let multiplier = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.north) {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    }
                }
                // Bottom Left Corner
                else if x < fadeLengthInset && y < fadeLengthInset {
                    if chunkAddress.hasNeighbor(.south) && chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.southWest) {
                        let multiplierY = -2 * Float(fadeLength - x - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - y + fadeInset) / Float(fadeLength)
                        if multiplierX > multiplierY {
                            value += multiplierX
                        } else {
                            value += multiplierY
                        }
                    } else if chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.south) {
                        let multiplier = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.west) && chunkAddress.hasNeighbor(.south) {
                        let multiplier = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.south) {
                        let multiplierY = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    }
                }
                // Bottom Right Corner
                else if inverseX < fadeLengthInset && y < fadeLengthInset {
                    if chunkAddress.hasNeighbor(.south) && chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.southEast) {
                        let multiplierY = -2 * Float(fadeLength - inverseX - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - y + fadeInset) / Float(fadeLength)
                        if multiplierX > multiplierY {
                            value += multiplierX
                        } else {
                            value += multiplierY
                        }
                    } else if chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.south) {
                        let multiplier = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.east) && chunkAddress.hasNeighbor(.south) {
                        let multiplier = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.south) {
                        let multiplierY = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    }
                }
                // Top
                else if x >= fadeLengthInset && inverseX >= fadeLengthInset && inverseY < fadeLengthInset && !chunkAddress.hasNeighbor(.north) {
                    let multiplier = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                    value += multiplier
                }
                // Bottom
                else if x >= fadeLengthInset && inverseX >= fadeLengthInset && y < fadeLengthInset && !chunkAddress.hasNeighbor(.south) {
                    let multiplier = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                    value += multiplier
                }
                // Left
                else if y >= fadeLengthInset && inverseY >= fadeLengthInset && x < fadeLengthInset && !chunkAddress.hasNeighbor(.west) {
                    let multiplier = -2 * Float(fadeLength - x - fadeInset) / Float(fadeLength)
                    value += multiplier
                }
                // Right
                else if y >= fadeLengthInset && inverseY >= fadeLengthInset && inverseX < fadeLengthInset && !chunkAddress.hasNeighbor(.east) {
                    let multiplier = -2 * Float(fadeLength - inverseX - fadeInset) / Float(fadeLength)
                    value += multiplier
                }
                
                let color = getColorForFloat(number: value)
                
                
                if (x == 0 || y == 0) && false {
                    chunkData.colors.append(contentsOf: [Float(color.redValue) + 0.4,
                                                         Float(color.greenValue) + 0.4,
                                                         Float(color.blueValue) + 0.4])
                } else if false {
                    
                } else {
                    chunkData.colors.append(contentsOf: [Float(color.redValue),
                                                         Float(color.greenValue),
                                                         Float(color.blueValue)])
                }
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
