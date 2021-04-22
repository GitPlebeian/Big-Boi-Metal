
import UIKit
import Metal
import GameKit

enum TileType: Int, CaseIterable {
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
    var types: [TileType] = []
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

class EditMapLayer: RenderLayer {
    
    // MARK: Properties
    
    weak var touchController: EngineTouchController!
    
    let chunkSize:   Int   = 48
    let cellSize:    Float = 44
    var fadeInset:   Int = 0
    var fadeLength:  Int = 20
    
    var vertices: [Float] = []
    var colors: [Float] = []
    
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
    
    // MARK: Init
    
    init(touchController: EngineTouchController) {
        self.touchController = touchController
        let noiseSource = GKPerlinNoiseSource(frequency: frequency,
                                              octaveCount: octaveCount,
                                              persistence: persistence,
                                              lacunarity: lacunarity,
                                              seed: seed)
        self.noiseSource = noiseSource
        super.init()
        
        setupImageRendering()
    }
    
    // MARK: Deinit
    
    deinit {
        print("Map Layer Deinit")
    }
    
    // MARK: Rendering
    
    override func setPipelineState() {
        self.pipelineState = RenderPipelineStateLibrary.shared.pipelineState(.MapMarchingSquares)
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        
        if vertices.count != 0 {
            // Render Marching Squares Map

            encoder.setRenderPipelineState(pipelineState)
            
            var transform = touchController.vertexTransform
            var scale     = touchController.vertexScale
            var width     = touchController.width
            var height    = touchController.height
            var gridSize  = self.cellSize

            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            encoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
            encoder.setVertexBytes(&transform, length: 8, index: 2)
            encoder.setVertexBytes(&scale, length: 4, index: 3)
            encoder.setVertexBytes(&width, length: 4, index: 4)
            encoder.setVertexBytes(&height, length: 4, index: 5)
            encoder.setVertexBytes(&gridSize, length: 4, index: 6)
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count / 2)
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
            clearSelectedChunks()
            let chunkAddress = ChunkAddress(chunk: chunk, index: chunks.count)
            
            chunks[chunk] = chunkAddress
            
            updateChunksForNewChunk(chunkAddress)
        }
        updateMapBuffer()
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
    func getTypeForCell(chunkCordinate: IntCordinate, cell: Cell) -> TileType? {
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

        var types: [Int] = []

//        print("MAP: \(width) | \(height)")

        let startingY = lowestChunk * chunkSize
        let endingY = (highestChunk + 1) * chunkSize

        let startingX = furthestLeftChunk * chunkSize
        let endingX = (furthestRightChunk + 1) * chunkSize

//        print("Starting Y: \(startingY) | EndingY: \(endingY) | StartingX: \(startingX) | EndingX: \(endingX)")

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
                    types.append(TileType.superDeepWater.rawValue)
                }
            }
        }

        let map = MapSave(width: width, height: height, types: types)
        
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!
        var topController = keyWindow.rootViewController!
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        let ac = UIAlertController(title: "Save Map", message: nil, preferredStyle: .alert)
            ac.addTextField()

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            guard let mapName = ac.textFields![0].text else {return}
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                // process files
                for url in fileURLs {
                    print(url.lastPathComponent)
                    if mapName + ".json" == url.lastPathComponent {
                        let alertController = UIAlertController(title: "Name Already Taken", message: nil, preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertController.addAction(ok)
                        let override = UIAlertAction(title: "Override", style: .destructive) { (_) in
                            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                            let documentDirectory = paths[0]
                            let fileName = "\(mapName).json"
                            let fullURL = documentDirectory.appendingPathComponent(fileName)
                            print("Writing To URL: \(fullURL)")
                            let jsonEncoder = JSONEncoder()
                            do {
                                let data = try jsonEncoder.encode(map)
                                try data.write(to: fullURL)
                            } catch let e {
                                print(e)
                            }
                        }
                        alertController.addAction(override)
                        topController.present(alertController, animated: true)
                        return
                    }
                }
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentDirectory = paths[0]
                let fileName = "\(mapName).json"
                let fullURL = documentDirectory.appendingPathComponent(fileName)
                print("Writing To URL: \(fullURL)")
                let jsonEncoder = JSONEncoder()
                do {
                    let data = try jsonEncoder.encode(map)
                    try data.write(to: fullURL)
                } catch let e {
                    print(e)
                }
                
            } catch {
                print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
            
        }
        ac.addAction(submitAction)
        topController.present(ac, animated: true)
    }
    
    // MARK: Helpers
    
    // Setup Image Rendering
    private func setupImageRendering() {
//        let image = UIImage(named: "testSprite")!
//
//        let imageRef = image.cgImage!
//        
//        let width = imageRef.width
//        let height = imageRef.height
//        
//        let bitsPerPixel = 4
//        let bitsPerComponent = 8
//        let bytesPerRow = width * bitsPerPixel
//    
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        
//        let data = UnsafeMutableRawPointer.allocate(byteCount: height * width * 4, alignment: 0)
//        
//        let context = CGContext(data: data,
//                                width: width,
//                                height: height,
//                                bitsPerComponent: bitsPerComponent,
//                                bytesPerRow: bytesPerRow,
//                                space: colorSpace,
//                                bitmapInfo: CGImageAlphaInfo.last.rawValue)
        
        
        
//        CGColorSpaceRelease
        
        
//        uint8_t *rawData = (uint8_t *)calloc(height * width * 4, sizeof(uint8_t));
//        NSUInteger bytesPerPixel = 4;
//        NSUInteger bytesPerRow = bytesPerPixel * width;
//        NSUInteger bitsPerComponent = 8;
//        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
//                                                     bitsPerComponent, bytesPerRow, colorSpace,
//                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//        CGColorSpaceRelease(colorSpace);
//
//        // Flip the context so the positive Y axis points down
//        CGContextTranslateCTM(context, 0, height);
//        CGContextScaleCTM(context, 1, -1);
//
//        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
//        CGContextRelease(context);
    }
    
    // Update Map Buffers
    private func updateMapBuffer() {
        if vertices.count == 0 {
            return
        }
        vertexBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertices, length: vertices.count * 4, options: [])
        colorBuffer = GraphicsDevice.Device.makeBuffer(bytes: colors, length: colors.count * 4, options: [])
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
