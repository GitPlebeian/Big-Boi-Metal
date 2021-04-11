////
////  Test3GridLayer.swift
////  game
////
////  Created by Jackson Tubbs on 3/18/21.
////
//
//import UIKit
//import Metal
//
//class GridLayer: RenderLayer {
//
//    // MARK: Properties
//
////    weak var controller: Test3GameController?
//
//    var gridColor: UIColor = .black
//
//    private var vertices: [Float] = [-1, 1, 1, -1]
//
//    // MARK: Rendering
//
//    override func setPipelineState() {
////        self.pipelineState = Test3RenderPipelineStateLibrary.shared.pipelineState(.Grid)
//    }
//
//    override func render(_ encoder: MTLRenderCommandEncoder) {
//
//        encoder.setRenderPipelineState(pipelineState)
//
//        guard let controller = controller else {return}
//
//        if controller.gridOn == false {
//            return
//        }
//
//        var transform = controller.view.vertexTransform
//        var scale     = controller.view.vertexScale
//        var width     = controller.view.width
//        var height    = controller.view.height
//        var gridSize  = controller.map.chunkSize
//        var color     = (Float(gridColor.redValue),
//                         Float(gridColor.greenValue),
//                         Float(gridColor.blueValue),
//                         Float(1))
//
//        calculateVertices()
//
//        let vertexBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertices, length: vertices.count * 4, options: [])
//
//        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        encoder.setVertexBytes(&transform, length: 8, index: 1)
//        encoder.setVertexBytes(&scale, length: 4, index: 2)
//        encoder.setVertexBytes(&width, length: 4, index: 3)
//        encoder.setVertexBytes(&height, length: 4, index: 4)
//        encoder.setVertexBytes(&gridSize, length: 4, index: 5)
//        encoder.setVertexBytes(&color, length: 16, index: 6)
//        encoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertices.count / 2)
//    }
//
//    // MARK: Helpers
//
//    // Calculate Vertices
//    func calculateVertices() {
//
//        guard let controller = controller else {return}
//
//        vertices = []
//
//        let visibleXCells = controller.view.width / controller.map.cellSize * controller.view.vertexScale
//        let xStep: Float = 2 / Float(visibleXCells)
//        let visibleYCells = controller.view.height / controller.map.cellSize * controller.view.vertexScale
//        let yStep: Float = 2 / Float(visibleYCells)
//
//        let transformX = controller.view.vertexTransform.0.truncatingRemainder(dividingBy: xStep)
//        let transformY = controller.view.vertexTransform.1.truncatingRemainder(dividingBy: yStep)
//
//        for xIndex in 0..<Int(visibleXCells + 3) {
//            if xIndex % 2 == 0 {
//                let x = xStep * Float(xIndex / 2)
//                vertices.append(contentsOf: [0 - x + transformX, 1, 0 - x + transformX, -1])
//            } else {
//                let x = xStep * Float(xIndex / 2)
//                vertices.append(contentsOf: [0 + x + transformX, 1, 0 + x + transformX, -1])
//            }
//        }
//        for yIndex in 0..<Int(visibleYCells + 3) {
//            if yIndex % 2 == 0 {
//                let y = yStep * Float(yIndex / 2)
//                vertices.append(contentsOf: [-1, 0 + y - transformY, 1, 0 + y - transformY])
//            } else {
//                let y = yStep * Float(yIndex / 2)
//                vertices.append(contentsOf: [-1, 0 - y - transformY, 1, 0 - y - transformY])
//            }
//        }
//    }
//}
