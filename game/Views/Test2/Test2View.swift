//
//  Test2View.swift
//  game
//
//  Created by Jackson Tubbs on 11/28/20.
//

import UIKit
import Metal

// MARK: Structures

//struct VertexIn {
//    let position: SIMD2 // <x,y>
//    let color: SIMD4 // <R,G,B,A>
//}

class Test2View: UIView {
    
    
    
    // MARK: Properties
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var vertexBuffer: MTLBuffer!
    var vertexColorBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    var didSetupView = false
    override var bounds: CGRect {
        didSet {
            if !didSetupView {
                setupViews()
                didSetupView = true
            }
        }
    }
    let defaultGridWidth: Int = 16
    
    // MARK: Views
    
    var cells: [UIView] = []
    
    // MARK: Style Guide
    
    // MARK: OJBC
    
    // Game Loop
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    // MARK: Helpers
    
    // Render
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.071,
            green: 0.071,
            blue: 0.071,
            alpha: 1)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(vertexColorBuffer, offset: 0, index: 1)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 5, instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
    // MARK: Setup Views
    
    func setupViews() {
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = layer.bounds
        metalLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        layer.addSublayer(metalLayer)
        
        let vertexData: [Float] = [
            -0.5, -0.5,
            -0.5,  0.5,
            0.5, -0.5,
            0.5, 0.5,
            2, 0
        ]
        
        let vertexColors: [Float] = [
            1, 0, 0,
            0, 1, 0,
            0, 0, 1,
            1, 0, 1,
            0, 1, 1
        ]
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        let dataSize2 = vertexColors.count * MemoryLayout.size(ofValue: vertexColors[0])
        vertexColorBuffer = device.makeBuffer(bytes: vertexColors, length: dataSize2, options: [])
        
        // 1
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment2")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex2")
        
        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // 3
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue() // End of setup
        
        // Display some shit
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: .default)
    }
}
