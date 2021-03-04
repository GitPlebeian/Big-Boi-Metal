//
//  GameView3.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import UIKit

protocol GameViewDelegate3: class {
    func update(_ completion: @escaping () -> Void)
}

class GameView3: UIView {
    
    // MARK: Properties
    
    // Delegate
    weak var delegate:   GameViewDelegate3?
    
    var engine:          Engine3!
    var objects:         [Object]   = []
    
    // Updates
    var updateComplete:  Bool       = true
    
    // Window
    var height:          Float      = 0
    var width:           Float      = 0
    
    let defaultGridWidth: Int = 300
    var yGridHeight: Int!
    
    // MARK: Gestures
    
    weak var panGesture:   UIPanGestureRecognizer!
    weak var pinchGesture: UIPinchGestureRecognizer!
    weak var tapGesture:   UITapGestureRecognizer!
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        height = Float(frame.height)
        width  = Float(frame.width)
        self.engine = Engine3()
        engine.clearColor = [Double(UIColor.background1.redValue),
                             Double(UIColor.background1.greenValue),
                             Double(UIColor.background1.blueValue)]
        engine.delegate = self
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Action
    
    // Tapped
    @objc func tapped() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        
        let location = getAdjustedPointInCordinateSpace(point: FloatPoint(tapGesture.location(in: self)))
        print("\nLocation: \(location)")
        let xCube = (location.x) / 2 * Float(defaultGridWidth)
        let yCube = (location.y) / 2 * Float(yGridHeight)
        print("X Cube:   \(Int(xCube.rounded(.up)))")
        print("Y Cube:   \(Int(yCube.rounded(.up)))")
    }
    
    // Panned
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
    
    // Scaled
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
    
    // Add Object
    func addObject(_ object: Object, layer: Int) {
        objects.append(object)
        engine.updateData()
    }
    
    // Wipe Data
    func wipeData() {
        objects = []
        engine.updateData()
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        // Engine
        addSubview(engine)
        engine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            engine.topAnchor.constraint(equalTo: topAnchor),
            engine.leadingAnchor.constraint(equalTo: leadingAnchor),
            engine.trailingAnchor.constraint(equalTo: trailingAnchor),
            engine.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: Style Guide
    
    // MARK: OJBC
    
    // Game Loop
    @objc func gameloop() {
        autoreleasepool {
            self.render()
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

        print("Total Cells: \(vertexData.2)")
        print("Data Size: \((dataSize + dataSize2))")
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Time: \(diff)")
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
}

extension GameView3: EngineDelegate3 {
    
    // Update
    func update() {
        updateComplete = false
        
        delegate?.update {
            DispatchQueue.main.async {
                self.engine.updateData()
                self.updateComplete = true
            }
        }
    }
}
