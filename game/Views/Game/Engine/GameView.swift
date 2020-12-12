//
//  GameView.swift
//  game
//
//  Created by Jackson Tubbs on 12/11/20.
//

import UIKit

class GameView: UIView {
    
    // MARK: Properties
    
    // Vertex
    var vertices:        [Float]    = []
    var colors:          [Float]    = []
    var transforms:      [Float]    = []
    var rotations:       [Float]    = []
    var globalTransform: FloatPoint = FloatPoint()
    var scale:           Float      = 1
    
    // Window
    var height:          Float      = 0
    var width:           Float      = 0
    var didSetBounds:    Bool       = false
    override var bounds: CGRect {
        didSet {
            if didSetBounds == false {
                height = Float(bounds.height)
                width  = Float(bounds.width)
                didSetBounds = true
                
                setupViews()
            }
        }
    }
    
    // MARK: Subviews
    
    weak var render:     Renderer!
    
    // MARK: Gesture
    
    weak var tapGesture: UITapGestureRecognizer!
    
    // MARK: Style Guide
    
    // MARK: Action
    
    // Tapped
    @objc private func tapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        let position = FloatPoint(tapGesture.location(in: self))
        addTriangle(at: position)
    }
    
    // MARK: Helpers
    
    // Add Triangle
    func addTriangle(at position: FloatPoint) {
        var triangle = ShapeHelper.getTriangle()
        scaleShape(shape: &triangle, metric: .width, scale: Float.random(in: 50...200))
        vertices.append(contentsOf: triangle.vertices)
        colors.append(contentsOf: triangle.colors)
        transforms.append(position.x)
        transforms.append(position.y)
        rotations.append(Float.random(in: 0..<360))
    }
    
    // Scale Shape
    func scaleShape(shape: inout Shape, metric: ShapeScalingMetric, scale: Float) {
        for index in 0..<shape.vertices.count {
            shape.vertices[index] *= scale / 2
        }
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        // Render
        let render = Renderer()
        render.delegate = self
        render.translatesAutoresizingMaskIntoConstraints = false
        addSubview(render)
        NSLayoutConstraint.activate([
            render.topAnchor.constraint(equalTo: topAnchor),
            render.leadingAnchor.constraint(equalTo: leadingAnchor),
            render.trailingAnchor.constraint(equalTo: trailingAnchor),
            render.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.render = render
        
        // Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
}

extension GameView: RendererDelegate {
    
}
