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

struct IntCordinate: Hashable {
    var x: Int
    var y: Int
    
    init(_ x: Int = 0, _ y: Int = 0) {
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
    var maxVelocity: FloatPoint {get}
}

struct PlayerShip: Ship {
    
    var vertices:    [Float]    = [0,1,1,-1,-1,-1]
    var colors:      [Float]    = [0,1,0,0.404,0.082,0.922,0.404,0.082,0.922]
    var transform:   FloatPoint = FloatPoint()
    var rotation:    Float      = 0
    
    var velocity:    FloatPoint = FloatPoint()
    var maxVelocity: FloatPoint = FloatPoint(5, 5)
    
    mutating func update(velocity: FloatPoint) {
        self.velocity.x += velocity.x / 10
        self.velocity.y += velocity.y / 10
        if self.velocity.x > maxVelocity.x {
            self.velocity.x = maxVelocity.x
        }
        if self.velocity.x < -maxVelocity.x {
            self.velocity.x = -maxVelocity.x
        }
        if self.velocity.y > maxVelocity.y {
            self.velocity.y = maxVelocity.y
        }
        if self.velocity.y < -maxVelocity.y {
            self.velocity.y = -maxVelocity.y
        }
        
        transform.x += self.velocity.x
        transform.y += self.velocity.y
    }
}
