//
//  Data Structures.swift
//  game
//
//  Created by Jackson Tubbs on 12/8/20.
//

import UIKit

protocol ShapeProtocol {
    var vertices: [Float] {get set}
    var colors:   [Float] {get set}
    
    mutating func scaleShape(scale: Float)
}

extension ShapeProtocol {
    
    mutating func scaleShape(scale: Float) {
        for index in 0..<self.vertices.count {
            self.vertices[index] *= scale / 2
        }
    }
}

struct Shape {
    var vertices: [Float] = []
    var colors:   [Float] = []
}

struct FloatPoint {
    var x: Float
    var y: Float
    
    init(_ point: CGPoint = .zero) {
        x = Float(point.x)
        y = Float(point.y)
    }
    
    init(_ x: Float = 0, _ y: Float = 0) {
        self.x = x
        self.y = y
    }
}

struct Cordinate {
    var x:     Float = 0
    var y:     Float = 0
}

protocol Object: ShapeProtocol {
    var transform: FloatPoint { get set }
    var rotation:  Float      { get set }
}

protocol Ship: Object {
    var velocity: FloatPoint {get set}
    
}

struct PlayerShip: Ship {
    
    var vertices: [Float]     = [0,1,1,-1,-1,-1]
    var colors: [Float]       = [1,0,0,1,1,1,1,1,1]
    var transform: FloatPoint = FloatPoint()
    var rotation: Float       = 0
    
    var velocity: FloatPoint  = FloatPoint()
}
