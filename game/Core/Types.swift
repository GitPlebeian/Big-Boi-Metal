//
//  Types.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import simd

protocol sizeable{ }
extension sizeable{
    static var size: Int{
        return MemoryLayout<Self>.size
    }
    
    static var stride: Int{
        return MemoryLayout<Self>.stride
    }
    
    static func size(_ count: Int)->Int{
        return MemoryLayout<Self>.size * count
    }
    
    static func stride(_ count: Int)->Int{
        return MemoryLayout<Self>.stride * count
    }
}

extension Float: sizeable { }
extension Float3: sizeable { }

struct Vertex: sizeable{
    var position: Float3
    var color: Float4
}

struct ModelConstants: sizeable{
    var modelMatrix = matrix_identity_float4x4
}

public typealias Float3 = SIMD3<Float>
public typealias Float4 = SIMD4<Float>
