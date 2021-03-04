//
//  Test3Type.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import Foundation

class Test3Shape {
    var vertices:  [Float]    = []
    var colors:    [Float]    = []
}

class Test3GameObject: Test3Shape {
    var transform: FloatPoint = FloatPoint()
    var rotation:  Float      = 0
    
    func scale(_ scale: Float) {
        for index in 0..<self.vertices.count {
            self.vertices[index] *= scale / 2
        }
    }
}
