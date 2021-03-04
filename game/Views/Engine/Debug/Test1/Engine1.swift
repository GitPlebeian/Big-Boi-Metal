//
//  Engine1.swift
//  game
//
//  Created by Jackson Tubbs on 12/12/20.
//

import UIKit

protocol EngineDelegate1: class {
    var  objects:        [Object] {get set}
    var  updateComplete: Bool     {get set}
    
    func update()
}

class Engine1: UIView {
    
    // MARK: Properties
    
    // Delegate
    weak var delegate:           EngineDelegate1?
    
    // Updating
    private var ups:             Int            = 60
    
    // Vertex
    private var vertices:        [Float]        = []
    private var colors:          [Float]        = []
    private var transforms:      [Float]        = []
    private var rotations:       [Float]        = []
    private var globalTransform: FloatPoint     = FloatPoint()
    private var scale:           Float          = 1
    
    // Rendering
    private var device:                    MTLDevice!
    private var metalLayer:                CAMetalLayer!
    private var pipelineState:             MTLRenderPipelineState!
    private var commandQueue:              MTLCommandQueue!
    private var timer:                     CADisplayLink!
    private var vertexBuffer:              MTLBuffer!
    private var shouldClear:               Bool = false
    
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
    
    // Style Guide
    var clearColor:                        [Double] = [0,0,0]
    
    // MARK: OJBC
    
    // Game Loop
    @objc func gameloop() {
        autoreleasepool {
            if delegate == nil {
                timer.invalidate()
            }
            self.render()
        }
    }
    
    // MARK: Render
    
    func render() {
        if shouldClear && vertices.count == 0 {
            guard let drawable = metalLayer?.nextDrawable() else { return }
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
                red: clearColor[0],
                green: clearColor[1],
                blue: clearColor[2],
                alpha: 0)

            let commandBuffer = commandQueue.makeCommandBuffer()!
            
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
            shouldClear = false
            return
        } else if vertices.count == 0 {
            return
        }
        shouldClear = true
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
            red: clearColor[0],
            green: clearColor[1],
            blue: clearColor[2],
            alpha: 0)

        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        
        
        let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * 4, options: [])
        let colorBuffer = device.makeBuffer(bytes: colors, length: colors.count * 4, options: [])
        let transformsBuffer = device.makeBuffer(bytes: transforms, length: transforms.count * 4, options: [])
        let rotationBuffer = device.makeBuffer(bytes: rotations, length: rotations.count * 4, options: [])
        
        var transform = (globalTransform.x, globalTransform.y)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(transformsBuffer, offset: 0, index: 2)
        renderEncoder.setVertexBuffer(rotationBuffer, offset: 0, index: 3)
        renderEncoder.setVertexBytes(&transform, length: 8, index: 4)
        renderEncoder.setVertexBytes(&scale, length: 4, index: 5)
        renderEncoder.setVertexBytes(&height, length: 4, index: 6)
        renderEncoder.setVertexBytes(&width, length: 4, index: 7)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count / 2)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func update() {
        if delegate?.updateComplete == false {
            return
        }
        delegate?.update()
    }
    
    // MARK: API

    // Update Data
    func updateData() {
        vertices = []
        colors = []
        transforms = []
        rotations = []
        guard let objects = delegate?.objects else {return}
        for object in objects {
            vertices.append(contentsOf: object.vertices)
            colors.append(contentsOf: object.colors)
            transforms.append(contentsOf: [object.transform.x, object.transform.y])
            rotations.append(object.rotation)
        }
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
        let fragmentProgram = defaultLibrary.makeFunction(name: "fragment_shader1")
        let vertexProgram = defaultLibrary.makeFunction(name: "vertex_shader1")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = device.makeCommandQueue()

        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: .default)
        
        let upsTimer = Timer(timeInterval: 1 / TimeInterval(ups), repeats: true) { [weak self] (timer) in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.update()
        }
        RunLoop.main.add(upsTimer, forMode: .common)
    }
}
