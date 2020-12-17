//
//  Engine.swift
//  game
//
//  Created by Jackson Tubbs on 12/12/20.
//

import UIKit

protocol EngineDelegate {
    var objects: [Object] {get set}
}

class Engine {
    
    // MARK: Properties
    
    // Delegate
    var delegate:        EngineDelegate!
    
    // Vertex
    var vertices:        [Float]        = []
    var colors:          [Float]        = []
    var transforms:      [Float]        = []
    var rotations:       [Float]        = []
    var globalTransform: FloatPoint     = FloatPoint()
    var scale:           Float          = 1
    
    // Window
    var height:          Float          = 0
    var width:           Float          = 0
     
    var renderer:        Renderer!
    
    // MARK: Init
    
    init(height: Float, width: Float) {
        self.height = height
        self.width = width
        let renderer = Renderer()
        renderer.delegate = self
        self.renderer = renderer
    }
    
    // MARK: API

    // Update Data
    func updateData() {
        vertices = []
        colors = []
        transforms = []
        rotations = []
        for object in delegate.objects {
            vertices.append(contentsOf: object.vertices)
            colors.append(contentsOf: object.colors)
            transforms.append(contentsOf: [object.transform.x, object.transform.y])
            rotations.append(object.rotation)
        }
    }
    
    // Layout Renderer
    func layoutRenderer(superView: UIView) {
        renderer.translatesAutoresizingMaskIntoConstraints = false
        superView.addSubview(renderer)
        NSLayoutConstraint.activate([
            renderer.topAnchor.constraint(equalTo: superView.topAnchor),
            renderer.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            renderer.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            renderer.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        ])
    }
}

extension Engine: RendererDelegate {
    
}
