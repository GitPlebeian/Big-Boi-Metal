////
////  Test3TestLayer.swift
////  game
////
////  Created by Jackson Tubbs on 3/11/21.
////
//
//import Metal
//
//class TestLayer: RenderLayer {
//
//    // MARK: Properties
//
////    weak var controller: Test3GameController?
//
//    var vertex: [Float] = []
//    var colors: [Float] = []
//    var transforms: [Float] = []
//
//    override func setPipelineState() {
////        self.pipelineState = Test3RenderPipelineStateLibrary.shared.pipelineState(.Basic)
//    }
//
//    override func render(_ encoder: MTLRenderCommandEncoder) {
//
//        if vertex.count == 0 {return}
//
//        guard let controller = controller else {return}
//
//        encoder.setRenderPipelineState(pipelineState)
//        
//        let vertexBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertex, length: vertex.count * 4, options: [])
//        let colorBuffer = GraphicsDevice.Device.makeBuffer(bytes: colors, length: colors.count * 4, options: [])
//
//        let transformBuffer = GraphicsDevice.Device.makeBuffer(bytes: transforms, length: transforms.count * 4, options: [])
//
//        var globalTransform = controller.view.vertexTransform
//        var scale     = controller.view.vertexScale
//        var width     = controller.view.width
//        var height    = controller.view.height
//
//        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
//        encoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
//        encoder.setVertexBuffer(transformBuffer, offset: 0, index: 2)
//        encoder.setVertexBytes(&scale, length: 4, index: 3)
//        encoder.setVertexBytes(&width, length: 4, index: 4)
//        encoder.setVertexBytes(&height, length: 4, index: 5)
//        encoder.setVertexBytes(&globalTransform, length: 8, index: 6)
//        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertex.count / 2)
//    }
//}
