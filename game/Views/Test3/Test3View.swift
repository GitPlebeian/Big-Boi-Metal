//
//  Test3View.swift
//  game
//
//  Created by Jackson Tubbs on 11/30/20.
//

import UIKit
import Metal

// MARK: Structures

struct FloatPoint {
    var x: Float
    var y: Float
    
    init(_ point: CGPoint = .zero) {
        x = Float(point.x)
        y = Float(point.y)
    }
}

class Test3View: UIView {
    
    // MARK: Properties
    
    var testValue: Float = 1
    
    var width: Float!
    var height: Float!
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var vertexBuffer: MTLBuffer!
    var vertexColorBuffer: MTLBuffer!
    
    var vertexTransform: (Float, Float) = (0, 0)
    var previousVertexTransform: FloatPoint = FloatPoint()
    var startPanLocation: FloatPoint = FloatPoint()
    
    var vertexScale: Float = 1
    var previousVertexScale: Float = 0
    var scaleStartLocationAjusted: FloatPoint = FloatPoint()
    var scaleStartLocation: FloatPoint = FloatPoint()
    
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    // Zooming And Panning
    let maxZoom: Float = 10
    let zoomSpeed: Float = 1
    
    var didSetupView = false
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
    let defaultGridWidth: Int = 300
    var yGridHeight: Int!
    
    // Vertex Stuff
    var vertexCount: Int = 0
    
    // MARK: Gestures
    
    weak var panGesture:   UIPanGestureRecognizer!
    weak var pinchGesture: UIPinchGestureRecognizer!
    weak var tapGesture: UITapGestureRecognizer!
    
    // MARK: Style Guide
    
    // MARK: OJBC
    
    // Game Loop
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    @objc func tapped() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        
        let location = getAdjustedPointInCordinateSpace(point: FloatPoint(tapGesture.location(in: self)))
        print("\nLocation: \(location)")
        let xCube = (location.x + 1) / 2 * Float(defaultGridWidth)
        let yCube = (location.y + 1) / 2 * Float(yGridHeight)
        print("X Cube:   \(Int(xCube.rounded(.up)))")
        print("Y Cube:   \(Int(yCube.rounded(.up)))")
    }
    
    @objc func panned() {
        var location = getPointInCordinateSpace(point: FloatPoint(panGesture.location(in: self)))
        if panGesture.state == .began {
            startPanLocation = location
        }
        
        location.x -= startPanLocation.x
        location.y -= startPanLocation.y
        
        vertexTransform = (location.x + previousVertexTransform.x, location.y + previousVertexTransform.y)

        if panGesture.state == .ended {
            previousVertexTransform.x += location.x
            previousVertexTransform.y += location.y
        }
    }
    
    @objc func scaled() {
        var scale = Float(pinchGesture.scale)
        if scale >= 1 {
            scale = scale / (scale * (scale))
        } else {
            scale = 1 / scale
        }
//        if scale - previousVertexScale > 1 {
//            scale = 1
//            previousVertexScale = 0
//        }
        
        scale = 1 - (1 - scale) * (1 - previousVertexScale)
        
        if pinchGesture.numberOfTouches >= 2 {
            
            let location = FloatPoint(pinchGesture.location(in: self))
            if pinchGesture.state == .began {
                scaleStartLocationAjusted = getAdjustedPointInCordinateSpace(point: location)
                scaleStartLocation = getPointInCordinateSpace(point: location)
            }
            
            vertexScale = scale - previousVertexScale
            
            let transform = getPointInCordinateSpace(point: location)
            
            let multiplier = 1 / vertexScale
            vertexTransform.0 = -scaleStartLocationAjusted.x * multiplier + scaleStartLocation.x + transform.x - scaleStartLocation.x
            vertexTransform.1 = -scaleStartLocationAjusted.y * multiplier + scaleStartLocation.y + transform.y - scaleStartLocation.y
        }
        
        if pinchGesture.state == .ended {
            previousVertexScale += 1 - scale
            previousVertexTransform.x = vertexTransform.0
            previousVertexTransform.y = vertexTransform.1
        }
    }
    
    // MARK: Helpers
    
    // Reset
    func reset() {
        vertexTransform = (0, 0)
        previousVertexTransform = FloatPoint()
        vertexScale = 1
        previousVertexScale = 0
        testValue = 1
    }
    
    func newGrid() {
        // Vertex
        let start = CFAbsoluteTimeGetCurrent()
        let vertexData = getVertexData()
        vertexCount = vertexData.1
        
        // Color
        let vertexColors = getColorData(cubeCount: vertexData.2)
        
        let dataSize = vertexData.0.count * MemoryLayout.size(ofValue: vertexData.0[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData.0, length: dataSize, options: [])

        let dataSize2 = vertexColors.count * MemoryLayout.size(ofValue: vertexColors[0])
        vertexColorBuffer = device.makeBuffer(bytes: vertexColors, length: dataSize2, options: [])
        print("Total Cells: \(vertexData.2)")
        print("Data Size: \((dataSize + dataSize2))")
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Time: \(diff)")
    }
    
    func test() {
        
    }
    
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
        renderEncoder.setVertexBytes(&vertexTransform, length: MemoryLayout.size(ofValue: vertexTransform), index: 2)
        renderEncoder.setVertexBytes(&vertexScale, length: MemoryLayout.size(ofValue: vertexScale), index: 3)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // Get Touch In Cordinate Space
    func getPointInCordinateSpace(point: FloatPoint) -> FloatPoint {
        var floatPoint = FloatPoint()
        floatPoint.x = point.x / width * 2 - 1
        floatPoint.y = point.y / height * 2 - 1
        return floatPoint
    }
    
    // Get Touch In Adjusted Cordinate Space
    func getAdjustedPointInCordinateSpace(point: FloatPoint) -> FloatPoint {
        var floatPoint = getPointInCordinateSpace(point: point)
        floatPoint.x = floatPoint.x * vertexScale + -vertexTransform.0 * vertexScale
        floatPoint.y = floatPoint.y * vertexScale + -vertexTransform.1 * vertexScale
        return floatPoint
    }
    
    // Get Vertex Data (Vertexs, Vertex Count, Cube Count)
    func getVertexData() -> ([Float], Int, Int) {

        let cellSize: CGFloat = bounds.width / CGFloat(defaultGridWidth)
        
        // Get Starting Point For Starting Y
        var yCellsRequired = Int((bounds.height / cellSize).rounded(.up))
        if yCellsRequired % 2 == 1 {
            yCellsRequired += 1
        }
        
        let xStepAmount = 2 / Float(bounds.width  / cellSize)
        let yStepAmount = 2 / Float(bounds.height / cellSize)
        
        let yStartingPoint1 = CGFloat(yCellsRequired) * CGFloat(yStepAmount)
        let yStartingPoint2 = yStartingPoint1 - 2
        let yStartingPoint =  yStartingPoint2 / 2

        var vertexData: [Float] = []
        
        for y in 0..<yCellsRequired {
            for x in 0..<defaultGridWidth {
                
                let cubeLeftX   = xStepAmount * Float(x) - 1
                let cubeRightX1  = xStepAmount * Float(x + 1) - 1
                let cubeRightX  = cubeRightX1
                
                let cubeTopY    = yStepAmount * Float(y) - 1 - Float(yStartingPoint)
                let cubeBottomY1 = yStepAmount * Float(y + 1) - 1
                let cubeBottomY = cubeBottomY1 - Float(yStartingPoint)
                
                vertexData.append(cubeLeftX)
                vertexData.append(cubeTopY)
                vertexData.append(cubeRightX)
                vertexData.append(cubeTopY)
                vertexData.append(cubeLeftX)
                vertexData.append(cubeBottomY)
                
                vertexData.append(cubeRightX)
                vertexData.append(cubeTopY)
                vertexData.append(cubeRightX)
                vertexData.append(cubeBottomY)
                vertexData.append(cubeLeftX)
                vertexData.append(cubeBottomY)
            }
        }
        yGridHeight = yCellsRequired
        return (vertexData, vertexData.count / 2, yCellsRequired * defaultGridWidth)
    }
    
    // Get Color Data
    func getColorData(cubeCount: Int) -> [Float] {
        
        var colors: [Float] = []
        
        for _ in 0..<cubeCount {
            
            switch Int.random(in: 0..<7) {
            case 0:
                let red = Float(UIColor.systemPink.redValue)
                let green = Float(UIColor.systemPink.greenValue)
                let blue = Float(UIColor.systemPink.blueValue)
                colors.append(contentsOf: [red, green, blue])
            case 1:
                let red = Float(UIColor.systemGreen.redValue)
                let green = Float(UIColor.systemGreen.greenValue)
                let blue = Float(UIColor.systemGreen.blueValue)
                colors.append(contentsOf: [red, green, blue])
            case 2:
                let red = Float(UIColor.systemBlue.redValue)
                let green = Float(UIColor.systemBlue.greenValue)
                let blue = Float(UIColor.systemBlue.blueValue)
                colors.append(contentsOf: [red, green, blue])
            case 3:
                let red = Float(UIColor.systemTeal.redValue)
                let green = Float(UIColor.systemTeal.greenValue)
                let blue = Float(UIColor.systemTeal.blueValue)
                colors.append(contentsOf: [red, green, blue])
            case 4:
                let red = Float(UIColor.systemYellow.redValue)
                let green = Float(UIColor.systemYellow.greenValue)
                let blue = Float(UIColor.systemYellow.blueValue)
                colors.append(contentsOf: [red, green, blue])
            case 5:
                let red = Float(UIColor.systemOrange.redValue)
                let green = Float(UIColor.systemOrange.greenValue)
                let blue = Float(UIColor.systemOrange.blueValue)
                colors.append(contentsOf: [red, green, blue])
            case 6:
                let red = Float(UIColor.systemIndigo.redValue)
                let green = Float(UIColor.systemIndigo.greenValue)
                let blue = Float(UIColor.systemIndigo.blueValue)
                colors.append(contentsOf: [red, green, blue])
            default: break
            }
        }
        return colors
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
        
        // Vertex
        let vertexData = getVertexData()
        vertexCount = vertexData.1
        
        // Color
        let vertexColors = getColorData(cubeCount: vertexData.2)
        
        let dataSize = vertexData.0.count * MemoryLayout.size(ofValue: vertexData.0[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData.0, length: dataSize, options: [])

        let dataSize2 = vertexColors.count * MemoryLayout.size(ofValue: vertexColors[0])
        vertexColorBuffer = device.makeBuffer(bytes: vertexColors, length: dataSize2, options: [])
        
        print("Data Size: \((dataSize + dataSize2))")

        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "test3_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "test3_vertex")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = device.makeCommandQueue()

        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: .default)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
        self.panGesture = panGesture
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaled))
        addGestureRecognizer(pinchGesture)
        self.pinchGesture = pinchGesture
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
}
