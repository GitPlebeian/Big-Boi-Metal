//
//  EngineTouchController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/3/21.
//

import UIKit

protocol EngineTouchControllerDelegate: class {
    func tapped(location: FloatPoint)
}

class EngineTouchController: UIView {
    
    // MARK: Properties
    
    weak var delegate: EngineTouchControllerDelegate?
    
    var vertexTransform:           (Float, Float) = (0, 0)
    private var previousVertexTransform:   FloatPoint     = FloatPoint()
    private var startPanLocation:          FloatPoint     = FloatPoint()
    
    var vertexScale:               Float          = 1
    private var previousVertexScale:       Float          = 0
    private var scaleStartLocationAjusted: FloatPoint     = FloatPoint()
    private var scaleStartLocation:        FloatPoint     = FloatPoint()
    
    // Bounds
    var maxZoom: Float = 50
    var minZoom: Float = 0.1
    var width: Float!
    var height: Float!
    private var didSetBounds: Bool = false
    override var bounds: CGRect {
        didSet {
            if didSetBounds == false {
                setupViews()
                didSetBounds = true
                width = Float(bounds.width)
                height = Float(bounds.height)
            }
        }
    }
    
    // MARK: Views
    
    // MARK: Gestures
    
    private weak var panGesture:   UIPanGestureRecognizer!
    private weak var pinchGesture: UIPinchGestureRecognizer!
    private weak var tapGesture:   UITapGestureRecognizer!
    
    // MARK: Actions
    
    // Tapped
    @objc func tapped() {
        delegate?.tapped(location: FloatPoint(tapGesture.location(in: self)))
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
        
        scale = 1 - (1 - scale) * (1 - previousVertexScale)
        
        if pinchGesture.numberOfTouches >= 2 {
            
            let location = FloatPoint(pinchGesture.location(in: self))
            if pinchGesture.state == .began {
                scaleStartLocationAjusted = getAdjustedPointInCordinateSpace(point: location)
                scaleStartLocation = getPointInCordinateSpace(point: location)
            }
            
            vertexScale = scale - previousVertexScale
            
            if vertexScale > maxZoom {
                vertexScale = maxZoom
            }
            
            let transform = getPointInCordinateSpace(point: location)
            
            let multiplier = 1 / vertexScale
            vertexTransform.0 = -scaleStartLocationAjusted.x * multiplier + scaleStartLocation.x + transform.x - scaleStartLocation.x
            vertexTransform.1 = -scaleStartLocationAjusted.y * multiplier + scaleStartLocation.y + transform.y - scaleStartLocation.y
        }
        
        if pinchGesture.state == .ended {
            if vertexScale == maxZoom {
                previousVertexScale = -maxZoom
            } else {
                previousVertexScale += 1 - scale
            }
            previousVertexTransform.x = vertexTransform.0
            previousVertexTransform.y = vertexTransform.1
        }
    }
    
    // MARK: Private
    
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
