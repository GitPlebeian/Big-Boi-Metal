//
//  GameView3.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import UIKit

protocol GameViewDelegate3: class {
    
}

class GameView3: UIView {
    
    // MARK: Properties
    
    // Delegate
    weak var delegate:   GameViewDelegate3?
    
    var engine:              Engine3!
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
        engine = Engine3(frame: CGRect(x: 0,
                                            y: 0,
                                            width: frame.width,
                                            height: frame.height),
                              clearColor: [Double(UIColor.mapDeepWater.redValue),
                                           Double(UIColor.mapDeepWater.greenValue),
                                           Double(UIColor.mapDeepWater.blueValue)])
        addSubview(engine)
        test3GameController = Test3GameController(view: self)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        print("GameView3 Deinit")
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
    func addLayer(_ layer: Test3RenderLayer, atLayer: Int) {
        engine.addLayer(layer, atLayer: atLayer)
    }
    
    // Wipe Data
    func wipeData() {
        engine.wipeData()
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
    func getAdjustedPointInCordinateSpace(point: FloatPoint, realWorldY: Bool = false) -> FloatPoint {
        var floatPoint = getPointInCordinateSpace(point: point)
        floatPoint.x = floatPoint.x * vertexScale + -vertexTransform.0 * vertexScale
        floatPoint.y = floatPoint.y * vertexScale + -vertexTransform.1 * vertexScale
        if realWorldY {
            floatPoint.y *= -1
        }
        return floatPoint
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned))
        addGestureRecognizer(panGesture)
        self.panGesture = panGesture
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaled))
        addGestureRecognizer(pinchGesture)
        self.pinchGesture = pinchGesture
    }
}
