//
//  Data Structures.swift
//  game
//
//  Created by Jackson Tubbs on 12/8/20.
//

import UIKit

struct FloatPoint {
    var x: Float
    var y: Float
    
    init(_ point: CGPoint = .zero) {
        x = Float(point.x)
        y = Float(point.y)
    }
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
}

struct Cordinate {
    var gridX: Int = 0
    var gridY: Int = 0
    var x:     Float = 0
    var y:     Float = 0
    
}

protocol Object {
    var cordinate: Cordinate { get set }
}
