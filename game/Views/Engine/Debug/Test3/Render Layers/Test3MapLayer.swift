//
//  Test3MapLayer.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import UIKit
import Metal

struct ChunkData {
    var cells: [Float] = []
    var colors: [Float] = []
}

class Test3MapLayer: Test3RenderLayer {
    
    // MARK: Properties
    
    weak var controller: Test3GameController?
    
    let chunkSize:   Int   = 8
    let cellSize:    Float = 44
    
    var cells: [Float] = []
    var colors: [Float] = []
    
    
    // MARK: Rendering
    
    override func setPipelineState() {
        self.pipelineState = Test3RenderPipelineStateLibrary.shared.pipelineState(.Map)
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        
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
    func addChunk(_ x: Int, _ y: Int) {
            
        let chunk = getChunkData(x, y)
        cells.append(contentsOf: chunk.cells)
        colors.append(contentsOf: chunk.colors)
    }
    
    // MARK: Helpers
    
    // Get Chunk Data
    func getChunkData(_ chunkX: Int, _ chunkY: Int) -> ChunkData {
        var chunk = ChunkData()
        for x in 0..<chunkSize {
            for y in 0..<chunkSize {
                chunk.cells.append(Float(x))
                chunk.cells.append(Float(y))
                switch Int.random(in: 0..<7) {
                case 0:
                    let red = Float(UIColor.systemPink.redValue)
                    let green = Float(UIColor.systemPink.greenValue)
                    let blue = Float(UIColor.systemPink.blueValue)
                    chunk.colors.append(contentsOf: [red, green, blue])
                case 1:
                    let red = Float(UIColor.systemGreen.redValue)
                    let green = Float(UIColor.systemGreen.greenValue)
                    let blue = Float(UIColor.systemGreen.blueValue)
                    chunk.colors.append(contentsOf: [red, green, blue])
                case 2:
                    let red = Float(UIColor.systemBlue.redValue)
                    let green = Float(UIColor.systemBlue.greenValue)
                    let blue = Float(UIColor.systemBlue.blueValue)
                    chunk.colors.append(contentsOf: [red, green, blue])
                case 3:
                    let red = Float(UIColor.systemTeal.redValue)
                    let green = Float(UIColor.systemTeal.greenValue)
                    let blue = Float(UIColor.systemTeal.blueValue)
                    chunk.colors.append(contentsOf: [red, green, blue])
                case 4:
                    let red = Float(UIColor.systemYellow.redValue)
                    let green = Float(UIColor.systemYellow.greenValue)
                    let blue = Float(UIColor.systemYellow.blueValue)
                    chunk.colors.append(contentsOf: [red, green, blue])
                case 5:
                    let red = Float(UIColor.systemOrange.redValue)
                    let green = Float(UIColor.systemOrange.greenValue)
                    let blue = Float(UIColor.systemOrange.blueValue)
                    chunk.colors.append(contentsOf: [red, green, blue])
                case 6:
                    let red = Float(UIColor.systemIndigo.redValue)
                    let green = Float(UIColor.systemIndigo.greenValue)
                    let blue = Float(UIColor.systemIndigo.blueValue)
                    chunk.colors.append(contentsOf: [red, green, blue])
                default: break
                }
            }
        }
        return chunk
    }
    
    func newGrid() {
        // Vertex
//        let start = CFAbsoluteTimeGetCurrent()
//        let vertexData = getVertexData()
//        vertexCount = vertexData.1
//
//        // Color
//        let vertexColors = getColorData(cubeCount: vertexData.2)
//
//        print("Total Cells: \(vertexData.2)")
//        print("Data Size: \((dataSize + dataSize2))")
//        let diff = CFAbsoluteTimeGetCurrent() - start
//        print("Time: \(diff)")
    }
    
    // Get Vertex Data (Vertexs, Vertex Count, Cube Count)
//    func getVertexData() -> ([Float], Int, Int) {
//
//        let cellSize: CGFloat = bounds.width / CGFloat(defaultGridWidth)
//
//        // Get Starting Point For Starting Y
//        var yCellsRequired = Int((bounds.height / cellSize).rounded(.up))
//        if yCellsRequired % 2 == 1 {
//            yCellsRequired += 1
//        }
//
//        let xStepAmount = 2 / Float(bounds.width  / cellSize)
//        let yStepAmount = 2 / Float(bounds.height / cellSize)
//
//        let yStartingPoint1 = CGFloat(yCellsRequired) * CGFloat(yStepAmount)
//        let yStartingPoint2 = yStartingPoint1 - 2
//        let yStartingPoint =  yStartingPoint2 / 2
//
//        var vertexData: [Float] = []
//
//        for y in 0..<yCellsRequired {
//            for x in 0..<defaultGridWidth {
//
//                let cubeLeftX   = xStepAmount * Float(x) - 1
//                let cubeRightX1  = xStepAmount * Float(x + 1) - 1
//                let cubeRightX  = cubeRightX1
//
//                let cubeTopY    = yStepAmount * Float(y) - 1 - Float(yStartingPoint)
//                let cubeBottomY1 = yStepAmount * Float(y + 1) - 1
//                let cubeBottomY = cubeBottomY1 - Float(yStartingPoint)
//
//                vertexData.append(cubeLeftX)
//                vertexData.append(cubeTopY)
//                vertexData.append(cubeRightX)
//                vertexData.append(cubeTopY)
//                vertexData.append(cubeLeftX)
//                vertexData.append(cubeBottomY)
//
//                vertexData.append(cubeRightX)
//                vertexData.append(cubeTopY)
//                vertexData.append(cubeRightX)
//                vertexData.append(cubeBottomY)
//                vertexData.append(cubeLeftX)
//                vertexData.append(cubeBottomY)
//            }
//        }
//        yGridHeight = yCellsRequired
//        return (vertexData, vertexData.count / 2, yCellsRequired * defaultGridWidth)
//    }
    
//    // Get Color Data
//    func getColorData(cubeCount: Int) -> [Float] {
//
//        var colors: [Float] = []
//
//        for _ in 0..<cubeCount {
//
//            switch Int.random(in: 0..<7) {
//            case 0:
//                let red = Float(UIColor.systemPink.redValue)
//                let green = Float(UIColor.systemPink.greenValue)
//                let blue = Float(UIColor.systemPink.blueValue)
//                colors.append(contentsOf: [red, green, blue])
//            case 1:
//                let red = Float(UIColor.systemGreen.redValue)
//                let green = Float(UIColor.systemGreen.greenValue)
//                let blue = Float(UIColor.systemGreen.blueValue)
//                colors.append(contentsOf: [red, green, blue])
//            case 2:
//                let red = Float(UIColor.systemBlue.redValue)
//                let green = Float(UIColor.systemBlue.greenValue)
//                let blue = Float(UIColor.systemBlue.blueValue)
//                colors.append(contentsOf: [red, green, blue])
//            case 3:
//                let red = Float(UIColor.systemTeal.redValue)
//                let green = Float(UIColor.systemTeal.greenValue)
//                let blue = Float(UIColor.systemTeal.blueValue)
//                colors.append(contentsOf: [red, green, blue])
//            case 4:
//                let red = Float(UIColor.systemYellow.redValue)
//                let green = Float(UIColor.systemYellow.greenValue)
//                let blue = Float(UIColor.systemYellow.blueValue)
//                colors.append(contentsOf: [red, green, blue])
//            case 5:
//                let red = Float(UIColor.systemOrange.redValue)
//                let green = Float(UIColor.systemOrange.greenValue)
//                let blue = Float(UIColor.systemOrange.blueValue)
//                colors.append(contentsOf: [red, green, blue])
//            case 6:
//                let red = Float(UIColor.systemIndigo.redValue)
//                let green = Float(UIColor.systemIndigo.greenValue)
//                let blue = Float(UIColor.systemIndigo.blueValue)
//                colors.append(contentsOf: [red, green, blue])
//            default: break
//            }
//        }
//        return colors
//    }
}
