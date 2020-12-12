//
//  Renderer.swift
//  game
//
//  Created by Jackson Tubbs on 12/11/20.
//

import UIKit
import Metal

protocol RendererDelegate: class {
    var vertices:        [Float]    {get set}
    var colors:          [Float]    {get set}
    var transforms:      [Float]    {get set}
    var rotations:       [Float]    {get set}
    var globalTransform: FloatPoint {get set}
    var scale:           Float      {get set}
}

class Renderer: UIView {
    
    // MARK: Properties
    
    weak var delegate: RendererDelegate!
    
    // Rendering
    private var device:                    MTLDevice!
    private var metalLayer:                CAMetalLayer!
    private var pipelineState:             MTLRenderPipelineState!
    private var commandQueue:              MTLCommandQueue!
    private var timer:                     CADisplayLink!
    private var vertexBuffer:              MTLBuffer!
    
    // Bounds
    private var width:                     Float!
    private var height:                    Float!
    private var didSetupView =             false
    override var bounds: CGRect {
        didSet {
            if !didSetupView {
                width = Float(bounds.width)
                height = Float(bounds.height)
                setupViews()
                didSetupView = true
            }
        }
    }
    
    // MARK: OJBC
    
    // Game Loop
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    // Render
    func render() {
        if delegate.vertices.count == 0 {
            return
        }
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: 0.071,
            green: 0.071,
            blue: 0.071,
            alpha: 0)

        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        
        
        let vertexBuffer = device.makeBuffer(bytes: delegate.vertices, length: delegate.vertices.count * 4, options: [])
        let colorBuffer = device.makeBuffer(bytes: delegate.colors, length: delegate.colors.count * 4, options: [])
        let transformsBuffer = device.makeBuffer(bytes: delegate.transforms, length: delegate.transforms.count * 4, options: [])
        let rotationBuffer = device.makeBuffer(bytes: delegate.rotations, length: delegate.rotations.count * 4, options: [])
        
        var globalTransform = (delegate.globalTransform.x, delegate.globalTransform.y)
        var scale = delegate.scale
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(transformsBuffer, offset: 0, index: 2)
        renderEncoder.setVertexBuffer(rotationBuffer, offset: 0, index: 3)
        renderEncoder.setVertexBytes(&globalTransform, length: 8, index: 4)
        renderEncoder.setVertexBytes(&scale, length: 4, index: 5)
        renderEncoder.setVertexBytes(&height, length: 4, index: 6)
        renderEncoder.setVertexBytes(&width, length: 4, index: 7)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: delegate.vertices.count / 2)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: Setup Views
    
    func setupViews() {
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.contentsScale = self.window?.screen.scale ?? 1.0
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = layer.bounds
        metalLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        layer.addSublayer(metalLayer)

        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_shader")
        let vertexProgram = defaultLibrary.makeFunction(name: "vertex_shader")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = device.makeCommandQueue()

        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: .default)
    }
}
