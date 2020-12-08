//
//  Test4View.swift
//  game
//
//  Created by Jackson Tubbs on 12/6/20.
//

import UIKit
import Metal

protocol Test4ViewDelegate: class {
    func tapped(x: Int, y: Int)
    func getColors() -> [Float]
}

class Test4View: UIView {
    
    // MARK: Properties
    
    // Delegate
    weak var delegate: Test4ViewDelegate!
    
    // Rendering
    private var device:                    MTLDevice!
    private var metalLayer:                CAMetalLayer!
    private var vertexBuffer:              MTLBuffer!
    private var pipelineState:             MTLRenderPipelineState!
    private var commandQueue:              MTLCommandQueue!
    private var timer:                     CADisplayLink!
    
    // Transform
    private var vertexTransform:           (Float, Float) = (0, 0)
    private var previousVertexTransform:   FloatPoint = FloatPoint()
    private var startPanLocation:          FloatPoint = FloatPoint()
    
    // Scale
    private var vertexScale:               Float = 1
    private var previousVertexScale:       Float = 0
    private var scaleStartLocationAjusted: FloatPoint = FloatPoint()
    private var scaleStartLocation:        FloatPoint = FloatPoint()
    
    private var gridWidth:                 Int = 32
    private var gridHeight:                Int!
    private var adjustedCellWidth:         Float = 0
    private var adjustedCellHeight:        Float = 0
    private var rawTrueWidth:              Float!
    private var rawTrueHeight:             Float!
    
    // Bounds
    private var width:                     Float!
    private var height:                    Float!
    private var didSetupView =             false
    override var bounds: CGRect {
        didSet {
            print("Did Set Bounds: \(bounds)")
            if !didSetupView {
                width = Float(bounds.width)
                height = Float(bounds.height)
                setupViews()
                didSetupView = true
            }
        }
    }
    
    // Gestures
    
    private weak var panGesture:           UIPanGestureRecognizer!
    private weak var pinchGesture:         UIPinchGestureRecognizer!
    private weak var tapGesture:           UITapGestureRecognizer!
    
    // MARK: Style Guide
    
    // MARK: Init
    
    init(gridWidth: Int) {
        super.init(frame: .zero)
        self.gridWidth = gridWidth
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: OJBC
    
    // Game Loop
    @objc func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    // Tapped
    @objc func tapped() {
        guard let location = getCubeForTouch(point: FloatPoint(tapGesture.location(in: self))) else {return}
        delegate.tapped(x: location.0, y: location.1)
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
    
    func getGridWidth()  -> Int { gridWidth }
    func getGridHeight() -> Int { gridHeight }
    func getCellCount()  -> Int { gridHeight * gridWidth }
    
    // End Game
    func endGame() {
        timer.invalidate()
    }
    
    // Reset
    func reset() {
        vertexTransform = (0, 0)
        previousVertexTransform = FloatPoint()
        vertexScale = 1
        previousVertexScale = 0
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
        let colors = delegate.getColors()
        let vertexColorBuffer = device.makeBuffer(bytes: colors, length: colors.count * 4, options: [])
        renderEncoder.setVertexBuffer(vertexColorBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBytes(&vertexTransform, length: MemoryLayout.size(ofValue: vertexTransform), index: 2)
        renderEncoder.setVertexBytes(&vertexScale, length: MemoryLayout.size(ofValue: vertexScale), index: 3)
        renderEncoder.setVertexBytes(&adjustedCellWidth, length: MemoryLayout.size(ofValue: adjustedCellWidth), index: 4)
        renderEncoder.setVertexBytes(&adjustedCellHeight, length: MemoryLayout.size(ofValue: adjustedCellHeight), index: 5)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: gridHeight * gridWidth * 6, instanceCount: 1)
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
    
    // Get Cube For Touch
    func getCubeForTouch(point: FloatPoint) -> (Int, Int)? {
        var location = getAdjustedPointInCordinateSpace(point: point)
        let yMultiplier = rawTrueHeight / height
        let xMultiplier = rawTrueWidth / width
        location.x /= xMultiplier
        location.y /= yMultiplier
        let xCell = Int((location.x + 1) / 2 * Float(gridWidth))
        let yCell = Int((location.y + 1) / 2 * Float(gridHeight))
        if xCell < 0 || xCell >= gridWidth || yCell < 0 || yCell >= gridHeight {
            return nil
        }
        return (xCell, yCell)
    }
    
    // Get Vertex Data (Vertex)
    func getVertexData() -> ([Float]) {

        let cellSize: Float = width / Float(gridWidth)
        
        // Get Starting Point For Starting Y
        var gridHeight = Int((height / cellSize).rounded(.up))
        if gridHeight % 2 == 1 {
            gridHeight += 1
        }
        
        rawTrueWidth = Float(gridWidth) * cellSize
        rawTrueHeight = Float(gridHeight) * cellSize
        
        let xStepAmount = 2 / (width  / cellSize)
        let yStepAmount = 2 / (height / cellSize)
        
        adjustedCellWidth = xStepAmount
        adjustedCellHeight = yStepAmount
        
        let yStartingPoint1 = Float(gridHeight) * yStepAmount
        let yStartingPoint2 = yStartingPoint1 - 2
        let yStartingPoint =  yStartingPoint2 / 2

        var vertexData: [Float] = []
        
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                let cubeLeftX    = xStepAmount  * Float(x) - 1
                let cubeTopY     = yStepAmount  * Float(y) - 1 - Float(yStartingPoint)
                vertexData.append(cubeLeftX)
                vertexData.append(cubeTopY)
            }
        }
        self.gridHeight = gridHeight
        
        return (vertexData)
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
        
        let vertexSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexSize, options: [])
        
        print("Total Cells: \(gridWidth * gridHeight)")

        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "test4_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "test4_vertex")

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
