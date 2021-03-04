//
//  Test3Map.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import UIKit

class Test3Map: Test3GameObject {
    
    let chunkSize:   Int   = 8
    let gridSize:    Float = 50
//    var chunks:      [[]] = []
    
    // Add Chunk
    func addChunk(_ x: Int, _ y: Int) {
            
        let chunk = getChunkData(x, y)
        vertices.append(contentsOf: chunk.vertices)
        colors.append(contentsOf: chunk.colors)
        print(chunk.vertices.count / 12)
    }
    
    // Get Chunk Data
    func getChunkData(_ chunkX: Int, _ chunkY: Int) -> Test3Shape {
        let chunk = Test3Shape()
        for x in 0..<chunkSize {
            for y in 0..<chunkSize {
                
                let left   = gridSize * Float(x)
                let right  = gridSize * Float(x + 1)
                let top    = gridSize * Float(y)
                let bottom = gridSize * Float(y + 1)
                
                
                
//                chunk.vertices.append(left)
//                chunk.vertices.append(top)
//                chunk.vertices.append(left)
//                chunk.vertices.append(bottom)
//                chunk.vertices.append(right)
//                chunk.vertices.append(bottom)
                
//                chunk.vertices.append(left)
//                chunk.vertices.append(top)
//                chunk.vertices.append(right)
//                chunk.vertices.append(top)
//                chunk.vertices.append(right)
//                chunk.vertices.append(bottom)
                
//                chunk.colors.append(contentsOf: [1,0.2,0.2,0.2,1,0.2,0.2,0.2,1])
//                chunk.colors.append(contentsOf: [1,0.2,0.2,0.2,1,0.2,0.2,0.2,1])
                
//                switch Int.random(in: 0..<2) {
//                case 0:
//                    let red = Float(UIColor.systemPink.redValue)
//                    let green = Float(UIColor.systemPink.greenValue)
//                    let blue = Float(UIColor.systemPink.blueValue)
//                    chunk.colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
//                case 1:
//                    let red = Float(UIColor.systemGreen.redValue)
//                    let green = Float(UIColor.systemGreen.greenValue)
//                    let blue = Float(UIColor.systemGreen.blueValue)
//                    chunk.colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
////                case 2:
////                    let red = Float(UIColor.systemBlue.redValue)
////                    let green = Float(UIColor.systemBlue.greenValue)
////                    let blue = Float(UIColor.systemBlue.blueValue)
////                    chunk.colors.append(contentsOf: [red, green, blue])
////                case 3:
////                    let red = Float(UIColor.systemTeal.redValue)
////                    let green = Float(UIColor.systemTeal.greenValue)
////                    let blue = Float(UIColor.systemTeal.blueValue)
////                    chunk.colors.append(contentsOf: [red, green, blue])
////                case 4:
////                    let red = Float(UIColor.systemYellow.redValue)
////                    let green = Float(UIColor.systemYellow.greenValue)
////                    let blue = Float(UIColor.systemYellow.blueValue)
////                    chunk.colors.append(contentsOf: [red, green, blue])
////                case 5:
////                    let red = Float(UIColor.systemOrange.redValue)
////                    let green = Float(UIColor.systemOrange.greenValue)
////                    let blue = Float(UIColor.systemOrange.blueValue)
////                    chunk.colors.append(contentsOf: [red, green, blue])
////                case 6:
////                    let red = Float(UIColor.systemIndigo.redValue)
////                    let green = Float(UIColor.systemIndigo.greenValue)
////                    let blue = Float(UIColor.systemIndigo.blueValue)
////                    chunk.colors.append(contentsOf: [red, green, blue])
//                default: break
//                }
            }
        }
        chunk.vertices = [0, 0, 0, 50, 50, 0,
                          50, 0, 50, 50, 100, 0]
        
        for index in 0..<chunk.vertices.count / 2 {
            chunk.colors.append(Float.random(in: 0...1))
            chunk.colors.append(Float.random(in: 0...1))
            chunk.colors.append(Float.random(in: 0...1))
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

