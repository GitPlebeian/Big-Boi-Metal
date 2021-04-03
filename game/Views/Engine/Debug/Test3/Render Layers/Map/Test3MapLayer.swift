//
//  Test3MapLayer.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import UIKit
import Metal
import GameKit

struct Map: Codable {
    let width:  Int
    let height: Int
    let types:  [UInt8]
}

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
    case ignoreNeighbors = 13
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
    
    let chunkSize:   Int   = 64
    let cellSize:    Float = 44
    var fadeInset:   Int = 0
    var fadeLength:  Int = 0
    
    var vertices: [Float] = []
    var colors: [Float] = []
    
    var chunks: [IntCordinate : ChunkAddress] = [:]
    var selectedChunks: [IntCordinate] = []
    
    var vertexBuffer: MTLBuffer!
    var colorBuffer: MTLBuffer!
    
    var mapTexture: MTLTexture!
    
    // Debug
    
    var tappes: Int = 0
    
    // Perlin
    var noiseSource: GKNoiseSource
    var frequency:   Double = 1
    var octaveCount: Int = 8
    var persistence: Double = 0.52
    var lacunarity:  Double = 1.89
    var seed: Int32 = 0
    
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
        isCustomPass = true
    }
    
    override func render(_ commandBuffer: MTLCommandBuffer, _ drawableTexture: MTLTexture) {
        
        
        guard let controller = controller else {return}
        
        if vertices.count != 0 {
            // Render Marching Squares Map
            
//            var seeableXCells = Int((controller.view.width / controller.map.cellSize * controller.view.vertexScale).rounded(.up))
//            var seeableYCells = Int((controller.view.height / controller.map.cellSize * controller.view.vertexScale).rounded(.up))
            
            let drawableRenderPassDescriptor = MTLRenderPassDescriptor()
            drawableRenderPassDescriptor.colorAttachments[0].texture = drawableTexture
            drawableRenderPassDescriptor.colorAttachments[0].loadAction = .clear
            drawableRenderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: Double(UIColor.mapDarkSea.redValue),
                green: Double(UIColor.mapDarkSea.greenValue),
                blue: Double(UIColor.mapDarkSea.blueValue),
                alpha: 0)
            
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: drawableRenderPassDescriptor)!
            
            encoder.setRenderPipelineState(Test3RenderPipelineStateLibrary.shared.pipelineState(.Texture))
            
            let samplerDescriptor = MTLSamplerDescriptor()
            samplerDescriptor.minFilter             = MTLSamplerMinMagFilter.nearest
            samplerDescriptor.magFilter             = MTLSamplerMinMagFilter.nearest
            samplerDescriptor.mipFilter             = MTLSamplerMipFilter.nearest
            samplerDescriptor.maxAnisotropy         = 1
            samplerDescriptor.sAddressMode          = MTLSamplerAddressMode.clampToEdge
            samplerDescriptor.tAddressMode          = MTLSamplerAddressMode.clampToEdge
            samplerDescriptor.rAddressMode          = MTLSamplerAddressMode.clampToEdge
            samplerDescriptor.normalizedCoordinates = true
            samplerDescriptor.lodMinClamp           = 0
            samplerDescriptor.lodMaxClamp           = .greatestFiniteMagnitude
            
            let sampler = GraphicsDevice.Device.makeSamplerState(descriptor: samplerDescriptor)!
            
            var ratio: Float
            
            if UIScreen.main.bounds.width < UIScreen.main.bounds.height {
                ratio = Float(UIScreen.main.bounds.width / UIScreen.main.bounds.height)
            } else {
                ratio = Float(UIScreen.main.bounds.height / UIScreen.main.bounds.width)
            }
            
            let vertices: [Float] = [-0.8 * ratio, 0.8, 0.8 * ratio, -0.8, -0.8 * ratio, -0.8,
                                     0.8 * ratio, 0.8, 0.8 * ratio, -0.8, -0.8 * ratio, 0.8]
//
//            let vertices: [Float] = [-1, 1, 1, -1, -1, -1,
//                                     1, 1, 1, -1, -1, 1]
            
//            let xCellDiff1 = (controller.view.height / controller.map.cellSize * controller.view.vertexScale).rounded(.down)
//            let xCellDiff2 = controller.view.vertexTransform.0.remainder(dividingBy: xCellDiff1 * 2)
//            let xCellDiff3 = 0.3
//            let xCellDiff4 = 0.3
//
//            print(xCellDiff4)
//
//            let textureCords: [Float] = [0 + 0.1, 0, 1 - 0.1, 1, 0 + 0.1, 1,
//                                         1 - 0.1, 0, 1 - 0.1, 1, 0 + 0.1, 0]
            
//            let textureCords: [Float] = [0, 0 + 0.1, 1, 1 - 0.1, 0, 1 - 0.1,
//                                         1, 0 + 0.1, 1, 1 - 0.1, 0, 0 + 0.1]
            
            let textureCords: [Float] = [0, 0, 1, 1, 0, 1,
                                         1, 0, 1, 1, 0, 0]
            
            let buffer = GraphicsDevice.Device.makeBuffer(bytes: vertices, length: vertices.count * 4, options: [])
            let textureBuffer = GraphicsDevice.Device.makeBuffer(bytes: textureCords, length: textureCords.count * 4, options: [])
            
            encoder.setVertexBuffer(buffer, offset: 0, index: 0)
            encoder.setVertexBuffer(textureBuffer, offset: 0, index: 1)
            encoder.setFragmentTexture(mapTexture, index: 0)
            encoder.setFragmentSamplerState(sampler, index: 0)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count / 2)
            encoder.endEncoding()
        } else {
            // Clear Screen
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = drawableTexture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: Double(UIColor.mapDarkSea.redValue),
                green: Double(UIColor.mapDarkSea.greenValue),
                blue: Double(UIColor.mapDarkSea.blueValue),
                alpha: 0)
            
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderEncoder.setRenderPipelineState(Test3RenderPipelineStateLibrary.shared.pipelineState(.Basic))
            renderEncoder.endEncoding()
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
        
        print("Adding Chunk: \(chunk)")
        
//        if chunks[chunk] != nil {
////            if let indexOfChunk = selectedChunks.firstIndex(of: chunk) {
////                selectedChunks.remove(at: indexOfChunk)
////                tintChunkColors(color: UIColor.white, strength: 0.12, cordinate: chunk)
////            } else {
////                selectedChunks.append(chunk)
////                tintChunkColors(color: UIColor.white, strength: -0.12, cordinate: chunk)
////            }
//        } else {
//            let chunkAddress = ChunkAddress(chunk: chunk, index: chunks.count)
//
//            chunks[chunk] = chunkAddress
//
//            updateChunksForNewChunk(chunkAddress)
//            updateMapBuffer()
//        }
        
        switch tappes {
        case 0:
            let chunkAddress = ChunkAddress(chunk: IntCordinate(0, 0), index: chunks.count)
            
            chunks[IntCordinate(0, 0)] = chunkAddress
            
            updateChunksForNewChunk(chunkAddress)
            updateMapBuffer()
//        case 1:
//            let chunkAddress = ChunkAddress(chunk: IntCordinate(-1, 0), index: chunks.count)
//
//            chunks[IntCordinate(-1, 0)] = chunkAddress
//
//            updateChunksForNewChunk(chunkAddress)
//            updateMapBuffer()
        case 1:
            let chunkAddress = ChunkAddress(chunk: IntCordinate(-1, -1), index: chunks.count)

            chunks[IntCordinate(-1, -1)] = chunkAddress

            updateChunksForNewChunk(chunkAddress)
            updateMapBuffer()
//        case 3:
//            let chunkAddress = ChunkAddress(chunk: IntCordinate(0, -1), index: chunks.count)
//
//            chunks[IntCordinate(0, -1)] = chunkAddress
//
//            updateChunksForNewChunk(chunkAddress)
//            updateMapBuffer()
        default:
            break
        }
        tappes += 1
        
//        let afterChunksCount = Float(chunks.count)
//        let afterVertexCount = Float(vertexs.count)
//        let afterVertexSizeKB = Float(vertexs.count * 4) / 1024
//        let afterVertexSizeMB = Float(vertexs.count * 4) / 1024 / 1024
//        let afterColorsSizeKB = Float(newColors.count * 4) / 1024
//        let afterColorsSizeMB = Float(newColors.count * 4) / 1024 / 1024

//        print("""
//\n\nTotal Chunks:        \(afterChunksCount)
//Chunk / Vertex Ratio:    \(afterVertexCount / afterChunksCount)
//Chunk / Vertex Ratio KB: \(afterVertexSizeKB / afterChunksCount)
//Chunk / Vertex Ratio MB: \(afterVertexSizeMB / afterChunksCount)
//Chunk / Color  Ratio KB: \(afterColorsSizeKB / afterChunksCount)
//Chunk / Color  Ratio MB: \(afterColorsSizeMB / afterChunksCount)
//Chunk Vertex Count:      \(vertexs.count)
//Chunk Triangle Count:    \(vertexs.count / 6)
//Chunk Vertex Size KB:    \(afterVertexSizeKB)
//Chunk Vertex Size MB:    \(afterVertexSizeMB)
//Chunk Color Size MB:     \(afterColorsSizeMB)
//""")
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
    
    // Delete Chunks
    func deleteChunks() {
        vertices = []
        colors = []
        chunks.removeAll()
        selectedChunks = []
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
    
    // Export Map
    func exportMap() {
        
        if chunks.count == 0 {
            print("No chunks, can't export data")
            return
        }
        
        var furthestLeftChunk: Int = Int.max
        var furthestRightChunk: Int = Int.min
        var lowestChunk: Int = Int.max
        var highestChunk: Int = Int.min
        
        for keyValueChunk in chunks {
            let cordinate = keyValueChunk.key
            if cordinate.x < furthestLeftChunk {
                furthestLeftChunk = cordinate.x
            }
            if cordinate.x > furthestRightChunk {
                furthestRightChunk = cordinate.x
            }
            if cordinate.y < lowestChunk {
                lowestChunk = cordinate.y
            }
            if cordinate.y > highestChunk {
                highestChunk = cordinate.y
            }
        }
        
        let width = furthestRightChunk - furthestLeftChunk + 1
        let height = highestChunk - lowestChunk + 1
        
        var types: [UInt8] = []
        
        print("MAP: \(width) | \(height)")
        
        let startingY = lowestChunk * chunkSize
        let endingY = (highestChunk + 1) * chunkSize
        
        let startingX = furthestLeftChunk * chunkSize
        let endingX = (furthestRightChunk + 1) * chunkSize
        
        print("Starting Y: \(startingY) | EndingY: \(endingY) | StartingX: \(startingX) | EndingX: \(endingX)")
        
        for y in startingY..<endingY {
            for x in startingX..<endingX {
                var chunkX: Int
                var chunkY: Int
                
                if x >= 0 {
                    chunkX = x / chunkSize
                    chunkY = y / chunkSize
                } else {
                    chunkX = (x - chunkSize + 1) / chunkSize
                    chunkY = (y - chunkSize + 1) / chunkSize
                }
                
                var cellX = x
                if cellX < 0 {
                    cellX += 1
                    cellX *= -1
                    cellX %= chunkSize
                    cellX = chunkSize - cellX
                } else {
                    cellX %= chunkSize
                }
                var cellY = y
                if cellY < 0 {
                    cellY += 1
                    cellY *= -1
                    cellY %= chunkSize
                    cellY = chunkSize - cellY
                } else {
                    cellY %= chunkSize
                }
                
                if let cellType = getTypeForCell(chunkCordinate: IntCordinate(chunkX, chunkY), cell: Cell(x: cellX, y: cellY)) {
                    types.append(cellType.rawValue)
                } else {
                    types.append(CellType.superDeepWater.rawValue)
                }
            }
        }
        
        let map = Map(width: width, height: height, types: types)
        
//        var pathOptional: URL?
//        do {
//            pathOptional = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        } catch let e {
//            print(e)
//        }
//
//        guard let path = pathOptional else {return}
        
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let documentDirectory = paths[0]
//        let fileName = "map\(width)x\(height).json"
//        let fullURL = documentDirectory.appendingPathComponent(fileName)
//
//        let jsonEncoder = JSONEncoder()
//        do {
//            let data = try jsonEncoder.encode(map)
//            try data.write(to: fullURL)
//        } catch let e {
//            print(e)
//        }
        
        guard let urls = FileManager.default.urls(for: .documentDirectory) else {return}
        
        for url in urls {
            print(url.lastPathComponent)
        }
    }
    
    // MARK: Helpers
    
    // Update Map Buffers
    private func updateMapBuffer() {
        
        if vertices.count == 0 {
            return
        }
        
        var furthestLeftChunk: Int = Int.max
        var furthestRightChunk: Int = Int.min
        var lowestChunk: Int = Int.max
        var highestChunk: Int = Int.min
        
        for keyValueChunk in chunks {
            let cordinate = keyValueChunk.key
            if cordinate.x < furthestLeftChunk {
                furthestLeftChunk = cordinate.x
            }
            if cordinate.x > furthestRightChunk {
                furthestRightChunk = cordinate.x
            }
            if cordinate.y < lowestChunk {
                lowestChunk = cordinate.y
            }
            if cordinate.y > highestChunk {
                highestChunk = cordinate.y
            }
        }
        
//        let widthb = furthestRightChunk - furthestLeftChunk + 1
//        let heightb = highestChunk - lowestChunk + 1
//
        
        
        var lowestXTest1: Float = .infinity
        var highestXTest1: Float = -.infinity
        var lowestYTest1: Float = .infinity
        var highestYTest1: Float = -.infinity
        for vertex in 0..<vertices.count / 2 {
            let x = vertices[vertex * 2]
            let y = vertices[vertex * 2 + 1]
            if x < lowestXTest1 {
                lowestXTest1 = x
            }
            if x > highestXTest1 {
                highestXTest1 = x
            }
            if y < lowestYTest1 {
                lowestYTest1 = y
            }
            if y > highestYTest1 {
                highestYTest1 = y
            }
        }
//        print("Lowest X: \(lowestXTest1) Highest X: \(highestXTest1) LY: \(lowestYTest1) HY: \(highestYTest1)")
        
//        var newVertices: [Float] = []
//
//        for index in 0..<vertices.count / 2 {
//            var x = vertices[index * 2]
//            var y = vertices[index * 2 + 1]
//
//            if x < 0 {
//
//            }
//
//            x = (x - lowestXTest1) / (Float(highestXTest1) - lowestXTest1) * 2 - 1
//            y = (y - lowestXTest1) / (Float(highestYTest1) - lowestXTest1) * 2 - 1
//            newVertices.append(contentsOf: [x, y])
//        }
        
        vertexBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertices, length: vertices.count * 4, options: [])
        colorBuffer = GraphicsDevice.Device.makeBuffer(bytes: colors, length: colors.count * 4, options: [])
        
        
        guard let controller = controller else {return}
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: 64 * 4, height: 64 * 4, mipmapped: false)
//            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: Int(controller.view.width), height: Int(controller.view.height), mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        
        mapTexture = GraphicsDevice.Device.makeTexture(descriptor: textureDescriptor)
        
        let commandBuffer = controller.view.engine.commandQueue.makeCommandBuffer()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = mapTexture
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        var chunkSize = Float(self.chunkSize)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBytes(&chunkSize, length: 4, index: 2)
        renderEncoder.setVertexBytes(&lowestXTest1, length: 4, index: 3)
        renderEncoder.setVertexBytes(&highestXTest1, length: 4, index: 4)
        renderEncoder.setVertexBytes(&lowestYTest1, length: 4, index: 5)
        renderEncoder.setVertexBytes(&highestYTest1, length: 4, index: 6)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count / 2)
        
        renderEncoder.endEncoding()
        commandBuffer.commit()
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
        
        let types = self.getChunkData(chunks[newChunk.chunk]!)
        chunks[newChunk.chunk]!.types = types
        chunksNeededUpdates.append(newChunk.chunk)
        
        // Update Other Graphics
        updateCellGraphics(chunksNeededUpdates)
    }
    
    // Update Chunks For Neighbor
    private func updateChunksForNeighbor(_ chunkAddress: ChunkAddress) {
        let types = self.getChunkData(chunkAddress)
        chunks[chunkAddress.chunk]!.types = types
    }
}
