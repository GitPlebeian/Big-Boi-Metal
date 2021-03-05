//
//  Test3PipelineStateLibrary.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import MetalKit

enum Test3RenderPipelineDescriptorTypes {
    case Basic
    case Map
}

class Test3RenderPipelineDescriptorLibrary {
    
    // MARK: Shared
    
    static let shared = Test3RenderPipelineDescriptorLibrary()
    
    private var renderPipelineDescriptors: [Test3RenderPipelineDescriptorTypes : Test3RenderPipelineDescriptor] = [:]
    
    // MARK: Init
    
    init() {
        createDefaultRenderPipelineDescriptors()
    }
    
    // MARK: Helpers
    
    private func createDefaultRenderPipelineDescriptors() {
        renderPipelineDescriptors.updateValue(Test3Basic_RenderPipelineDescriptor(), forKey: .Basic)
        renderPipelineDescriptors.updateValue(Test3Map_RenderPipelineDescriptor(), forKey: .Map)
    }
    
    public func descriptor(_ renderPipelineDescriptorType: Test3RenderPipelineDescriptorTypes) -> MTLRenderPipelineDescriptor {
        return renderPipelineDescriptors[renderPipelineDescriptorType]!.renderPipelineDescriptor
    }
    
}

protocol Test3RenderPipelineDescriptor {
    var name: String { get }
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor! { get }
}

public struct Test3Basic_RenderPipelineDescriptor: Test3RenderPipelineDescriptor{
    var name: String = "Basic Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    init(){
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = Test3ShaderLibrary.Shared.vertex(.Basic)
        renderPipelineDescriptor.fragmentFunction = Test3ShaderLibrary.Shared.fragment(.Basic)
//        renderPipelineDescriptor.vertexDescriptor = VertexDescriptorLibrary.Descriptor(.Basic)
    }
}
public struct Test3Map_RenderPipelineDescriptor: Test3RenderPipelineDescriptor{
    var name: String = "Map Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    init(){
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexFunction = Test3ShaderLibrary.Shared.vertex(.Map)
        renderPipelineDescriptor.fragmentFunction = Test3ShaderLibrary.Shared.fragment(.Map)
//        renderPipelineDescriptor.vertexDescriptor = VertexDescriptorLibrary.Descriptor(.Basic)
    }
}
