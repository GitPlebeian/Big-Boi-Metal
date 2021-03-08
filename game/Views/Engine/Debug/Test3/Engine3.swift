//
//  Engine3.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import UIKit

class Engine3: UIView {
    
    // MARK: Properties
    
    // Library
    
    
    // Updating
    private var ups:             Int             = 60
    private var updateCompleted: Bool            = false
    
    // Layers
    private var renderLayers: [Test3RenderLayer] = []
    
    // View Modifiers
    private var globalTransform: FloatPoint      = FloatPoint()
    private var scale:           Float           = 1
    
    // Rendering
    private var metalLayer:                CAMetalLayer!
    private var clearingPipelineState:     MTLRenderPipelineState!
    private var commandQueue:              MTLCommandQueue!
    private var timer:                     CADisplayLink!
    private var shouldClear:               Bool = false
    
    // Bounds
    private let width:                     Float
    private let height:                    Float
    
    // Style Guide
    var clearColor:                        [Double]
    
    // MARK: Init
    
    init(frame: CGRect,
         clearColor: [Double]) {
        
        self.width = Float(frame.width)
        self.height = Float(frame.height)
        self.clearColor = clearColor
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        print("Engine 3 Deinit")
    }
    
    // MARK: Override
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        timer.invalidate()
    }
    
    // MARK: OJBC
    
    // Game Loop
    @objc func gameloop() {
        autoreleasepool { [weak self] in
            guard let self = self else {return}
            self.render()
        }
    }
    
    // MARK: Public
    
    // Add Layer
    func addLayer(_ layer: Test3RenderLayer, atLayer: Int) {
        renderLayers.append(layer)
    }
    
    // Wipe Data
    func wipeData() {
        renderLayers = []
    }
    
    // MARK: Helpers
    
    // MARK: Render
    
    private func render() {
        if shouldClear && renderLayers.count == 0 {
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
            renderEncoder.setRenderPipelineState(clearingPipelineState)
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
            shouldClear = false
            return
        } else if renderLayers.count == 0 {
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
        
        for layer in renderLayers {
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
            layer.render(renderEncoder)
            renderEncoder.endEncoding()
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func update() {
        if updateCompleted == false {
            return
        }
        updateCompleted = false
        
        for layer in renderLayers {
            layer.update()
        }
        
        updateCompleted = true
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first
        
        metalLayer = CAMetalLayer()
        metalLayer.device = GraphicsDevice.Device
        metalLayer.contentsScale = keyWindow?.screen.scale ?? 1.0

        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = layer.bounds
        metalLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        layer.addSublayer(metalLayer)

        clearingPipelineState = Test3RenderPipelineStateLibrary.shared.pipelineState(.Basic)
        
        commandQueue = GraphicsDevice.Device.makeCommandQueue()

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
