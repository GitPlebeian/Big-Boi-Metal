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
    
    var engine:              Engine3!
    var objects:             [Test3GameObject]   = []
    var test3GameController: Test3GameController!
    
    // Updates
    var updateComplete:  Bool       = true
    
    // Window
    var height:          Float      = 0
    var width:           Float      = 0
    
    var vertexTransform: (Float, Float) = (0, 0)
    var previousVertexTransform: FloatPoint = FloatPoint()
    var startPanLocation: FloatPoint = FloatPoint()
    
    var vertexScale: Float = 1
    var previousVertexScale: Float = 0
    var scaleStartLocationAjusted: FloatPoint = FloatPoint()
    var scaleStartLocation: FloatPoint = FloatPoint()
    
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
        
        test3GameController = Test3GameController(view: self)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    // Tapped
    @objc func tapped() {
        test3GameController.tapped(tapGesture.location(in: self))
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
    func addObject(_ object: Test3GameObject, layer: Int) {
        objects.append(object)
        engine.updateData()
    }
    
    // Wipe Data
    func wipeData() {
        objects = []
        engine.updateData()
    }
    
    // Reset
    func reset() {
        vertexTransform = (0, 0)
        previousVertexTransform = FloatPoint()
        vertexScale = 1
        previousVertexScale = 0
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
