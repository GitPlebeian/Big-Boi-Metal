//
//  Types.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/3/21.
//

import UIKit

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
