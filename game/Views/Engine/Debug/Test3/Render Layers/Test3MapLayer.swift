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

enum CellGraphicType: UInt8 {
    case whole = 0
    
    case other = 255
}

struct ChunkData {
    var cells:  [Float] = []
    var colors: [Float] = []
    var types: [CellType] = []
    var typeInt: [UInt8] = []
//    mutating func assignCellTypes() {
//        for (index, cellType) in types.enumerated() {
//            // Get Surrounding Cells
//            let upCell = getCell(index, .north)
//            let leftCell = getCell(index, .west)
//            let rightCell = getCell(index, .east)
//            let downCell = getCell(index, .south)
//
//            // Assign Cell Type
//
//            // Whole Cell
//            if upCell.rawValue == cellType.rawValue &&
//                leftCell.rawValue == cellType.rawValue &&
//                rightCell.rawValue == cellType.rawValue &&
//                downCell.rawValue == cellType.rawValue {
//
//                graphicType.append(CellGraphicType.whole.rawValue)
//
//                let color = Test3MapLayer.getColorForType(cellType)
//                colors.append(contentsOf: [Float(color.redValue),
//                                           Float(color.greenValue),
//                                           Float(color.blueValue)])
//            } else {
//                graphicType.append(CellGraphicType.other.rawValue)
//                colors.append(contentsOf: [0,0,0,0,0,0])
//                continue
//            }
//
//            let color = Test3MapLayer.getColorForType(cellType)
//
//            colors.append(contentsOf: [Float(color.redValue),
//                                       Float(color.greenValue),
//                                       Float(color.blueValue)])
//        }
//    }
    
    // Get Cell
//    private func getCell(_ cellIndex: Int, _ direction: Direction) -> CellType {
//        switch direction {
//        case .north:
//            if cellIndex - Test3MapLayer.chunkSize < 0 {
//                return types[cellIndex]
//            }
//            return types[cellIndex - Test3MapLayer.chunkSize]
//        case .west:
//            if cellIndex - 1 < 0 {
//                return types[cellIndex]
//            }
//            return types[cellIndex - 1]
//        case .east:
//            if cellIndex + 1 >= types.count {
//                return types[cellIndex]
//            }
//            return types[cellIndex + 1]
//        case .south:
//            if cellIndex + Test3MapLayer.chunkSize >= types.count {
//                return types[cellIndex]
//            }
//            return types[cellIndex + Test3MapLayer.chunkSize]
//        default: fatalError("Unknown Cell Direction")
//        }
//    }
}

struct ChunkAddress {
    var chunk: IntCordinate
    var index: Int
    var types: [CellType] = []
    var typeInt: [UInt8] = []
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
    
    var testArray1: [CellType] = []
    var testArray2: [CellType] = []
    
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
        
//        var oldChunkAddress = ChunkAddress(chunk: IntCordinate(-1, 0), index: 0)
//        let oldChunkData = getChunkDataOld(oldChunkAddress)
//        cells.append(contentsOf: oldChunkData.cells)
//        colors.append(contentsOf: oldChunkData.colors)
//        oldChunkAddress.types = oldChunkData.types
//        chunks[oldChunkAddress.chunk] = oldChunkAddress
        
        
//        for x in -1...1 {
//            var newChunkAddress = ChunkAddress(chunk: IntCordinate(x, 0), index: 1)
//            let newChunkData = getChunkData(newChunkAddress)
//            newChunkAddress.types = newChunkData.types
//            chunks[newChunkAddress.chunk] = newChunkAddress
//            if x == -1 {
//                cells.append(contentsOf: newChunkData.cells)
//                colors.append(contentsOf: newChunkData.colors)
//            } else {
//                updateCellGraphics([newChunkAddress.chunk])
//            }
////            for y in -1...1 {
////
////            }
//        }
//        let x = 0
//        let y = 0
//        var newChunkAddress = ChunkAddress(chunk: IntCordinate(x, y), index: 1)
//        let newChunkData = getChunkData(newChunkAddress)
//        newChunkAddress.types = newChunkData.types
        
//        for y in 0..<chunkSize {
//            for x in 0..<chunkSize {
//                if (x == 25) {
//                }
//            }
//        }
        
//        testArray2 = newChunkAddress.types
        
//        print("Equal 2: \(testArray1 == testArray2)")
//
//        print("New New")
//        for (index, type) in newChunkAddress.types.enumerated() {
//            if index % (chunkSize + 1) == chunkSize {
//
//                print("\(type.rawValue)")
//            } else {
//                if type.rawValue != 0 {
//                    print("\(type.rawValue)", terminator: "")
//                } else {
//
//                    print("\(type.rawValue)", terminator: "")
//                }
//            }
//        }
//        print("")
//
//        chunks[newChunkAddress.chunk] = newChunkAddress
//        updateCellGraphics([newChunkAddress.chunk])
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
        
//        if vertexs.count == 0 {return}
        
        guard let controller = controller else {return}
        
        if cells.count != 0 {
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
        if vertexs.count != 0 {
            // Render Marching Squares Map
            encoder.setRenderPipelineState(Test3RenderPipelineStateLibrary.shared.pipelineState(.MapMarchingSquares))
            
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
            return
        }

        let chunkAddress = ChunkAddress(chunk: chunk, index: chunks.count)

        chunks[chunk] = chunkAddress

        updateChunksForNewChunk(chunkAddress)

        print("\nAdding Chunk: \(chunk.x) | \(chunk.y)\nCunks Loaded: \(chunks.count)\nMap Triangle Count: \(cells.count)")
    }
    
    // Clear Chunks
    func clearChunks() {
        cells = []
        colors = []
        chunks.removeAll()
    }
    
    // Reload Map
    func reloadMap() {
        
//        for address in chunks {
//            updateChunksForNeighbor(address.value)
//        }
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
//        cells.append(contentsOf: chunkData.cells)
//        colors.append(contentsOf: chunkData.colors)
        chunksNeededUpdates.append(newChunk.chunk)
        
        // Update Other Graphics
        updateCellGraphics(chunksNeededUpdates)
    }
    
    // Update Chunk Directions For New Direction
    
    // Update Chunks For Neighbor
    private func updateChunksForNeighbor(_ chunkAddress: ChunkAddress) {
        let chunkData = self.getChunkData(chunkAddress)
        chunks[chunkAddress.chunk]!.types = chunkData.types
//        colors.replaceSubrange((chunkAddress.index * chunkSize * chunkSize * 3)..<((chunkAddress.index + 1) * chunkSize * chunkSize * 3), with: chunkData.colors)
    }
    
    // Get Chunk Data
    private func getChunkData(_ chunkAddress: ChunkAddress) -> ChunkData {
        
        let chunk = chunkAddress.chunk
        
        let noise = GKNoise(noiseSource)
        
        let modifier: Double = 1
        
        if chunkAddress.chunk == IntCordinate(1, 0) {
            
        } else {
            
//            noise.move(by: SIMD3<Double>(Double(chunk.x) * modifier, 0, Double(chunk.y) * modifier))
        }
        
        
        let noiseMap = GKNoiseMap(noise,
                                  size: SIMD2<Double>(arrayLiteral: 1, 1),
                                  origin: SIMD2(arrayLiteral: 0, 0),
                                  sampleCount: SIMD2<Int32>(Int32(Int(chunkSize + 1)), Int32(chunkSize + 1)),
                                  seamless: true)
        
        let fadeLengthInset = fadeInset + fadeLength
        
        var chunkData = ChunkData()
        for y in 0..<chunkSize + 1 {
            for x in 0..<chunkSize + 1 {
                
                if chunk.x == -1 {
                    chunkData.cells.append(Float(x + chunk.x * chunkSize - 3))
                    chunkData.cells.append(Float(y + chunk.y * chunkSize))
                }
                
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
                let type = getTypeForFloat(value)
                chunkData.types.append(type)
                let color = getColorForType(type)
                chunkData.colors.append(contentsOf: [Float(color.redValue),
                                                     Float(color.greenValue),
                                                     Float(color.blueValue)])
                if x == 25 {
                    print("Value Y \(y): \(chunkData.types.last!)")
                }
            }
        }
        testArray1 = chunkData.types
        print()
        for (index, type) in chunkData.types.enumerated() {
            if index % (chunkSize + 1) == chunkSize {
                
                print("\(type.rawValue)")
            } else {
                if type.rawValue != 0 {
                    print("\(type.rawValue)", terminator: "")
                } else {
                    
                    print("\(type.rawValue)", terminator: "")
                }
            }
        }
        print("")
        
//        for y in 0..<chunkSize + 1 {
//            for x in 0..<chunkSize + 1 {
//                if (x == 25) {
////                    print("After Type Y \(chunkData.types[(x  * chunkSize) + y]))")
//                }
//            }
//        }
        
        return chunkData
    }
    
    // Update Cell Graphics
    func updateCellGraphics(_ chunkCordinates: [IntCordinate]) {
        
        vertexs = []
        newColors = []
        
//        var totalTypeCount = 0
//        for cordinate in chunkCordinates {
//            totalTypeCount += chunks[cordinate]!.types.count
//        }
//
//        print("\nChunks To Update Graphics: \(chunkCordinates.count) | Type Count: \(totalTypeCount) | Total Cells: \(chunkSize * chunkSize * chunkCordinates.count)")
        
        let address = chunks[chunkCordinates[0]]!
        
        var tmpVertex: [Float] = []
        var tmpColor: [Float] = []
        
        let mapLevel: CellType = .grass
        
        for mapLevel in CellType.allCases {
            let layerColor = getColorForType(mapLevel)
            for index in 0..<chunkSize * chunkSize {
                
                let y = index / (chunkSize)
                
                if index == 20 && address.chunk == IntCordinate(0,0) {
                    print("hi")
                }
                
                // Get Type
                var config: Int8 = 0
                if address.chunk == IntCordinate(1, 0) {
                    //                    if address.types[index + y] == mapLevel { // Bottom Left
                    //                        config += 15
                    //                    }
                    if address.types[index + 1 + y] == mapLevel { // Bottom Right
                        config += 15
                    }
                    //                    if address.types[index + chunkSize + y + 1] == mapLevel { // Top Left
                    //                        config += 15
                    //                    }
                    //                    if address.types[index + chunkSize + y + 2] == mapLevel { // Top Right
                    //                        config += 15
                    //                    }
                } else {
                    var materials: [CellType] = []
                    if !materials.contains(address.types[index + y]) {
                        materials.append(address.types[index + y])
                    }
                    if !materials.contains(address.types[index + y + 1]) {
                        materials.append(address.types[index + y + 1])
                    }
                    if !materials.contains(address.types[index + y + chunkSize + 1]) {
                        materials.append(address.types[index + y + chunkSize + 1])
                    }
                    if !materials.contains(address.types[index + y + chunkSize + 2]) {
                        materials.append(address.types[index + y + chunkSize + 2])
                    }
                    
                    if address.types[index + y] == mapLevel { // Bottom Left
                        config += 2
                    }
                    if address.types[index + 1 + y] == mapLevel { // Bottom Right
                        config += 1
                    }
                    if address.types[index + chunkSize + y + 1] == mapLevel { // Top Left
                        config += 8
                    }
                    if address.types[index + chunkSize + y + 2] == mapLevel { // Top Right
                        config += 4
                    }
                    if materials.count > 2 {
                        var lowestLevel = CellType.allCases.last!
                        for material in materials {
                            if material.rawValue < lowestLevel.rawValue {
                                lowestLevel = material
                            }
                        }
                        if mapLevel == lowestLevel {
                            config = 15
                        }
                    }
                }
                var vertexAndColors: ([Float], [Float])
                //                    if x == y {
                //                    } else {
                vertexAndColors = getVertexAndColorsForConfig(config, index: index, chunk: address.chunk, color: layerColor)
                //                        vertexAndColors = getVertexAndColorsForConfig(config, x: x, y: y, color: layerColor)
                //                    }
                
                tmpVertex.append(contentsOf: vertexAndColors.0)
                tmpColor.append(contentsOf: vertexAndColors.1)
                
            }
        }
        var counter: TimeInterval = 0
        for index in 0..<tmpVertex.count / 6 {
            counter += 0.001
            Timer.scheduledTimer(withTimeInterval: counter, repeats: false) { (timer) in
                timer.invalidate()
                let vStartIndex = index * 6
                let cStartIndex = index * 9

                for index in vStartIndex..<vStartIndex + 6 {
                    self.vertexs.append(tmpVertex[index])
                }

                for index in cStartIndex..<cStartIndex + 9 {
                    self.newColors.append(tmpColor[index])
                }

            }
        }
        
//        vertexs = tmpVertex
//        newColors = tmpColor
    }
    
    // Get Vertex And Colors For Config
    func getVertexAndColorsForConfig(_ config: Int8, index: Int, chunk: IntCordinate, color: UIColor) -> ([Float],[Float]) {
        
        let x = Float(index % chunkSize + chunkSize * chunk.x)
        let y = Float(index / chunkSize + chunkSize * chunk.y)
        
        let tlx = x // Top L
        let tly = y + 1
        let tmx = x + 0.5 // Top M
        let tmy = y + 1
        let trx = x + 1 // Top R
        let trY = y + 1
        
        let mlx = x // Middle L
        let mly = y + 0.5
        let mrx = x + 1
        let mry = y + 0.5
        
        let blx = x
        let bly = y + 0
        let bmx = x + 0.5
        let bmy = y + 0
        let brx = x + 1
        let bry = y + 0
        
        var vertexs: [Float] = []
        var colors: [Float] = []
        switch config {
        case 1:  vertexs = [bmx, bmy, mrx, mry, brx, bry]
//            for _ in 0..<vertexs.count / 2 {
//                colors.append(contentsOf: [Float(UIColor.red.redValue),
//                                           Float(UIColor.red.greenValue),
//                                           Float(UIColor.red.blueValue)])
//            }
//            return (vertexs,colors)
        case 2:  vertexs = [mlx, mly, bmx, bmy, blx, bly]
        case 3:  vertexs = [mlx, mly, brx, bry, blx, bly, mlx, mly, mrx, mry, brx, bry]
        case 4:  vertexs = [tmx, tmy, trx, trY, mrx, mry]
        case 5:  vertexs = [tmx, tmy, trx, trY, bmx, bmy, trx, trY, brx, bry, bmx, bmy]
        case 6:  vertexs = [tmx, tmy, trx, trY, mlx, mly, trx, trY, blx, bly, mlx, mly, trx, trY, bmx, bmy, blx, bly, trx, trY, mrx, mry, bmx, bmy]
        case 7:  vertexs = [tmx, tmy, blx, bly, mlx, mly, tmx, tmy, brx, bry, blx, bly, tmx, tmy, trx, trY, brx, bry]
        case 8:  vertexs = [tlx, tly, tmx, tmy, mlx, mly]
        case 9:  vertexs = [tlx, tly, bmx, bmy, mlx, mly, tlx, tly, brx, bry, bmx, bmy, tlx, tly, mrx, mry, brx, bry, tlx, tly, tmx, tmy, mrx, mry]
        case 10: vertexs = [tlx, tly, tmx, tmy, bmx, bmy, tlx, tly, bmx, bmy, blx, bly]
        case 11: vertexs = [tlx, tly, tmx, tmy, blx, bly, tmx, tmy, brx, bry, blx, bly, tmx, tmy, mrx, mry, brx, bry]
        case 12: vertexs = [tlx, tly, mrx, mry, mlx, mly, tlx, tly, trx, trY, mrx, mry]
        case 13: vertexs = [tlx, tly, bmx, bmy, mlx, mly, tlx, tly, trx, trY, bmx, bmy, trx, trY, brx, bry, bmx, bmy]
        case 14: vertexs = [tlx, tly, bmx, bmy, blx, bly, tlx, tly, trx, trY, bmx, bmy, trx, trY, mrx, mry, bmx, bmy]
        case 15: vertexs = [tlx, tly, brx, bry, blx, bly, tlx, tly, trx, trY, brx, bry]
        default: break
        }
        
//        if Int(x) % 4 == 0 {
//            vertexs = [tlx, tly, brx, bry, blx, bly, tlx, tly, trx, trY, brx, bry]
//            for _ in 0..<vertexs.count / 2 {
//                colors.append(contentsOf: [Float(UIColor.systemRed.redValue),
//                                           Float(UIColor.systemRed.greenValue),
//                                           Float(UIColor.systemRed.blueValue)])
//            }
//            return (vertexs, colors)
//        }

//        if x == 0 && y == 0 {
//            for _ in 0..<vertexs.count / 2 {
//                colors.append(contentsOf: [Float(UIColor.systemRed.redValue),
//                                           Float(UIColor.systemRed.greenValue),
//                                           Float(UIColor.systemRed.blueValue)])
//            }
//        } else if Int(x) == chunkSize - 1 && y == 0 {
//            for _ in 0..<vertexs.count / 2 {
//                colors.append(contentsOf: [Float(UIColor.systemGreen.redValue),
//                                           Float(UIColor.systemGreen.greenValue),
//                                           Float(UIColor.systemGreen.blueValue)])
//            }
//        } else if x == 0 && Int(y) == chunkSize - 1 {
//            for _ in 0..<vertexs.count / 2 {
//                colors.append(contentsOf: [Float(UIColor.systemBlue.redValue),
//                                           Float(UIColor.systemBlue.greenValue),
//                                           Float(UIColor.systemBlue.blueValue)])
//            }
//        } else if Int(x) == chunkSize - 1 && Int(y) == chunkSize - 1 {
//            for _ in 0..<vertexs.count / 2 {
//                colors.append(contentsOf: [Float(UIColor.white.redValue),
//                                           Float(UIColor.white.greenValue),
//                                           Float(UIColor.white.blueValue)])
//            }
//        } else {
//        }
        for _ in 0..<vertexs.count / 2 {
            colors.append(contentsOf: [Float(color.redValue),
                                       Float(color.greenValue),
                                       Float(color.blueValue)])
            //                let randomR = Float.random(in: 0...1)
            //                let randomG = Float.random(in: 0...1)
            //                let randomB = Float.random(in: 0...1)
            //                colors.append(contentsOf: [randomR,randomG,randomB,randomR,randomG,randomB,randomR,randomG,randomB])
        }
        return (vertexs, colors)
    }
    
    
    
    // Get Type For Float
    func getTypeForFloat(_ number: Float) -> CellType {
        if number <= -0.8 {
            return .superDeepWater
        } else if number <= -0.6 {
            return .deepWater
        } else if number <= -0.4 {
            return .water
        } else if number <= -0.2 {
            return .shallowWater
        } else if number <= 0 {
            return .beach
        } else if number <= 0.3 {
            return .grass
        } else if number <= 0.6 {
            return .forest
        } else if number <= 0.7 {
            return .mountain1
        } else if number <= 0.8 {
            return .mountain2
        } else if number <= 0.85 {
            return .mountain3
        } else if number <= 0.9 {
            return .mountain4
        } else {
            return .snow
        }
    }
    
    // Get Color For Type
    func getColorForType(_ type: CellType) -> UIColor {
        switch type {
        case .superDeepWater: return .mapSuperDeepWater
        case .deepWater: return .mapDeepWater
        case .water: return .mapWater
        case .shallowWater: return .mapShallowWater
        case .beach: return .mapBeach
        case .grass: return .mapGrass
        case .forest: return .mapForest
        case .mountain1: return .mapMountain1
        case .mountain2: return .mapMountain2
        case .mountain3: return .mapMountain3
        case .mountain4: return .mapMountain4
        case .snow: return .mapSnow
        }
    }
}
