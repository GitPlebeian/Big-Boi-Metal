//
//  Test3PipelineStateLibrary.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import MetalKit

enum RenderPipelineDescriptorTypes {
    case Basic
    case Map
    case MapMarchingSquares
    case Grid
    case Texture
}

class RenderPipelineDescriptorLibrary {
    
    // MARK: Shared
    
    static let shared = RenderPipelineDescriptorLibrary()
    
    private var renderPipelineDescriptors: [RenderPipelineDescriptorTypes : RenderPipelineDescriptor] = [:]
    
    // MARK: Init
    
    init() {
        createDefaultRenderPipelineDescriptors()
    }
    
    // MARK: Helpers
    
    private func createDefaultRenderPipelineDescriptors() {
        renderPipelineDescriptors.updateValue(Basic_RenderPipelineDescriptor(), forKey: .Basic)
        renderPipelineDescriptors.updateValue(Map_RenderPipelineDescriptor(), forKey: .Map)
        renderPipelineDescriptors.updateValue(MapMarchingSquares_RenderPipelineDescriptor(), forKey: .MapMarchingSquares)
        renderPipelineDescriptors.updateValue(Grid_RenderPipelineDescriptor(), forKey: .Grid)
        renderPipelineDescriptors.updateValue(Texture_RenderPipelineDescriptor(), forKey: .Texture)
    }
    
    public func descriptor(_ renderPipelineDescriptorType: RenderPipelineDescriptorTypes) -> MTLRenderPipelineDescriptor {
        return renderPipelineDescriptors[renderPipelineDescriptorType]!.renderPipelineDescriptor
    }
    
}

protocol RenderPipelineDescriptor {
    var name: String { get }
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor! { get }
}

public struct Basic_RenderPipelineDescriptor: RenderPipelineDescriptor{
    var name: String = "Basic Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    init(){
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = ShaderLibrary.Shared.vertex(.Basic)
        renderPipelineDescriptor.fragmentFunction = ShaderLibrary.Shared.fragment(.Basic)
    }
}
public struct Map_RenderPipelineDescriptor: RenderPipelineDescriptor{
    var name: String = "Map Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    init(){
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = ShaderLibrary.Shared.vertex(.Map)
        renderPipelineDescriptor.fragmentFunction = ShaderLibrary.Shared.fragment(.Map)
    }
}

public struct MapMarchingSquares_RenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Map Marching Squares Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    init(){
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = ShaderLibrary.Shared.vertex(.MapMarchingSquares)
        renderPipelineDescriptor.fragmentFunction = ShaderLibrary.Shared.fragment(.MapMarchingSquares)
    }
}

public struct Grid_RenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Grid Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    init(){
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = ShaderLibrary.Shared.vertex(.Grid)
        renderPipelineDescriptor.fragmentFunction = ShaderLibrary.Shared.fragment(.Grid)
    }
}

public struct Texture_RenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Texture Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    init(){
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
        renderPipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        renderPipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .one
        renderPipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderPipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = ShaderLibrary.Shared.vertex(.Texture)
        renderPipelineDescriptor.fragmentFunction = ShaderLibrary.Shared.fragment(.Texture)
    }
}
