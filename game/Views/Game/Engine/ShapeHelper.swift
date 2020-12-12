//
//  ShapeHelper.swift
//  game
//
//  Created by Jackson Tubbs on 12/11/20.
//

import Foundation

enum ShapeScalingMetric {
    case width
    case height
}

struct ShapeHelper {
    
    
    static func getTriangle() -> Shape {
        var triangle = Shape()
        triangle.vertices = [0,1,1,-1,-1,-1]
        for _ in 0..<9 {
            triangle.colors.append(Float.random(in: 0...1))
        }
        return triangle
    }
}

