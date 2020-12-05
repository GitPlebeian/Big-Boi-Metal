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
    var previousVertexTransform: (Float, Float) = (0, 0)
    var previousPanLocation: CGPoint!
    
    var vertexScale: Float = 1
    var previousVertexScale: Float = 0
    var previousScaleMoveValue: Float = 0
    
    var scaleSessionStartScaleLocation: FloatPoint = FloatPoint()
    
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
    let defaultGridWidth: Int = 20
    var yGridHeight: Int!
    
    // Vertex Stuff
    var vertexCount: Int = 0
    
    // MARK: Views
    
    weak var panGesture:   UIPanGestureRecognizer!
    weak var pinchGesture: UIPinchGestureRecognizer!
    weak var tapGesture: UITapGestureRecognizer!
    
    
    // MARK: Style Guide
    
    // MARK: OJBC
    
    // Game Loop
    @objc func gameloop() {
        autoreleasepool { [weak self] in
            self?.render()
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
        let location = panGesture.location(in: self)
        if panGesture.state == .began {
            previousPanLocation = location
        }
        let xTransform1 = location.x - previousPanLocation.x
        let xTransform2 = xTransform1 / bounds.width
        let xTransform = xTransform2 * 2
//        let yTransform1 = location.y - previousPanLocation.y
//        let yTransform2 = yTransform1 / bounds.height
//        let yTransform = yTransform2 * 2
        
//        vertexTransform = (Float(xTransform) + previousVertexTransform.0, Float(yTransform) + previousVertexTransform.1)
        vertexTransform = (Float(xTransform) + previousVertexTransform.0, 0)
        
        if panGesture.state == .ended {
            previousVertexTransform.0 = Float(xTransform) + previousVertexTransform.0
//            previousVertexTransform.1 = Float(yTransform) + previousVertexTransform.1
        }
        
        print("\nVertex Scale: \(vertexScale)")
        print("Transform: \(vertexTransform)")
    }
    
    @objc func scaled() {
//        print("\nPinch Scale:    \(pinchGesture.scale)")
//        print("Previous Scale: \(previousVertexScale)")
        let scale = Float(pinchGesture.scale)
        let originalScale = scale
//        print("Before Scale: \(scale)")
//        if scale > 1 {
//            scale = scale / (scale * (scale * 2))
//        } else {
//
//        }
//        print("After: \(scale)")
        vertexScale = scale + previousVertexScale
        
        // Transform
        
        if pinchGesture.state == .began {
            let location = FloatPoint(pinchGesture.location(in: self))
            scaleSessionStartScaleLocation = getAdjustedPointInCordinateSpace(point: location)
            
            print("\n\n\n\n\n\n\n\n\nNEW SCALE ----\n\n\n\n\n\n\n\n\n")
        }
        
        
        // Calculate Move Value

        let moveValue1: Float = (1 / (vertexScale) - 1)
        let moveValue2: Float = scaleSessionStartScaleLocation.x
        let moveValue3: Float = -moveValue1 * moveValue2
        let moveValue4: Float = moveValue3 + previousScaleMoveValue * moveValue1
        vertexTransform = (moveValue4, 0)
        
        print("\nVertex Scale:        \(vertexScale)")
        print("Transform X:         \(vertexTransform.0)")
        print("Previous Scale Move: \(previousScaleMoveValue)")
        print("Session Start Touch: \(scaleSessionStartScaleLocation.x)")
        print("Move Multiplier:     \(moveValue1)")
        
        if pinchGesture.state == .ended {
            previousScaleMoveValue = moveValue4
            previousVertexScale = originalScale - 1
//            previousVertexTransform.0 = Float(xTransform) + previousVertexTransform.0
            previousVertexTransform.0 = moveValue4
        }
    }
    
    // MARK: Helpers
    
    // Reset
    func reset() {
        vertexTransform = (0, 0)
        previousVertexTransform = (0, 0)
        vertexScale = 1
        previousVertexScale = 0
        testValue = 1
        
        previousScaleMoveValue = 0
    }
    
    func newGrid() {
        // Vertex
        let vertexData = getVertexData()
        vertexCount = vertexData.1
        
        // Color
        let vertexColors = getColorData(cubeCount: vertexData.2)
        
        let dataSize = vertexData.0.count * MemoryLayout.size(ofValue: vertexData.0[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData.0, length: dataSize, options: [])

        let dataSize2 = vertexColors.count * MemoryLayout.size(ofValue: vertexColors[0])
        vertexColorBuffer = device.makeBuffer(bytes: vertexColors, length: dataSize2, options: [])
        print("Total Cells: \(vertexData.2)")
        print("Data Size: \((dataSize + dataSize2) / 1000) KB")
    }
    
    func test() {
        vertexTransform.0 = 3
        vertexScale = 0.25
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
//        print("FloatPoint1: \(floatPoint)")
        return floatPoint
    }
    
    // Get Touch In Adjusted Cordinate Space
    func getAdjustedPointInCordinateSpace(point: FloatPoint) -> FloatPoint {
        var floatPoint = getPointInCordinateSpace(point: point)
//        print("FloatPoint2: \(floatPoint)")
//        print("Scale: \(vertexScale)")
//        print("Trans: \(vertexTransform)")
        floatPoint.x = floatPoint.x * vertexScale + -vertexTransform.0 * vertexScale
        floatPoint.y = floatPoint.y * vertexScale + -vertexTransform.1 * vertexScale
//        print("FloatPoint3: \(floatPoint)")
        return floatPoint
    }
    
    // Get Vertex Data (Vertexs, Vertex Count, Cube Count)
    func getVertexData() -> ([Float], Int, Int) {
        
//        print("Screen Width: \(bounds.width)")
//        print("Screen Height: \(bounds.height)")
        let cellSize: CGFloat = bounds.width / CGFloat(defaultGridWidth)
//        print("Cell Size: \(cellSize)")
//        print("Height / Cell Size: \(bounds.height / cellSize)")
//        print("Cells Needed To Fill Space: \((bounds.height / cellSize).rounded(.up))")
        
        // Get Starting Point For Starting Y
        var yCellsRequired = Int((bounds.height / cellSize).rounded(.up))
        if yCellsRequired % 2 == 1 {
            yCellsRequired += 1
        }
//        print("Cells Required: \(yCellsRequired * defaultGridWidth)")
//        print("Y Cells Required: \(yCellsRequired)")
        
        let xStepAmount = 2 / Float(bounds.width  / cellSize)
        let yStepAmount = 2 / Float(bounds.height / cellSize)
        
        let yStartingPoint1 = CGFloat(yCellsRequired) * CGFloat(yStepAmount)
        let yStartingPoint2 = yStartingPoint1 - 2
        let yStartingPoint =  yStartingPoint2 / 2
//        print("Starting Point: \(yStartingPoint)")

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
                
//                print("\nY Cell:       \(y)")
//                print("X Cell:       \(x)")
//                print("Cube Left X:  \(cubeLeftX)")
//                print("Cube Right X: \(cubeRightX)")
//                print("Cube Top Y:   \(cubeTopY)")
//                print("Cube BottomY: \(cubeBottomY)")
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
                colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
            case 1:
                let red = Float(UIColor.systemGreen.redValue)
                let green = Float(UIColor.systemGreen.greenValue)
                let blue = Float(UIColor.systemGreen.blueValue)
                colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
            case 2:
                let red = Float(UIColor.systemBlue.redValue)
                let green = Float(UIColor.systemBlue.greenValue)
                let blue = Float(UIColor.systemBlue.blueValue)
                colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
            case 3:
                let red = Float(UIColor.systemTeal.redValue)
                let green = Float(UIColor.systemTeal.greenValue)
                let blue = Float(UIColor.systemTeal.blueValue)
                colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
            case 4:
                let red = Float(UIColor.systemYellow.redValue)
                let green = Float(UIColor.systemYellow.greenValue)
                let blue = Float(UIColor.systemYellow.blueValue)
                colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
            case 5:
                let red = Float(UIColor.systemOrange.redValue)
                let green = Float(UIColor.systemOrange.greenValue)
                let blue = Float(UIColor.systemOrange.blueValue)
                colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
            case 6:
                let red = Float(UIColor.systemIndigo.redValue)
                let green = Float(UIColor.systemIndigo.greenValue)
                let blue = Float(UIColor.systemIndigo.blueValue)
                colors.append(contentsOf: [red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue, red, green, blue])
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
        
        print("Data Size: \((dataSize + dataSize2) / 1000) KB")

        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "test3_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "test3_vertex")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = device.makeCommandQueue()

        // Display some shit
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: .default)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned))
        addGestureRecognizer(panGesture)
        panGesture.delegate = self
        self.panGesture = panGesture
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaled))
        addGestureRecognizer(pinchGesture)
        pinchGesture.delegate = self
        self.pinchGesture = pinchGesture
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        self.tapGesture = tapGesture
    }
}

extension Test3View: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
