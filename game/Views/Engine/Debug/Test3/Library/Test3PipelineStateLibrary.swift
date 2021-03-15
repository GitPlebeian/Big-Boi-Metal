//
//  Test3PipelineDescriptorLibrary.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import MetalKit

enum Test3RenderPipelineStateTypes {
    case Map
    case Basic
    case MapMarchingSquares
}

class Test3RenderPipelineStateLibrary {
    
    // MARK: Shared
    
    static let shared = Test3RenderPipelineStateLibrary()
    
    // MARK: Properties
    
    private var renderPipelineStates: [Test3RenderPipelineStateTypes: Test3RenderPipelineState] = [:]
    
    // MARK: Init
    
    init() {
        createDefaultRenderPipelineStates()
    }
    
    func pipelineState(_ renderPipelineStateType: Test3RenderPipelineStateTypes) -> MTLRenderPipelineState {
        return (renderPipelineStates[renderPipelineStateType]?.renderPipelineState)!
    }
    
    // MARK: Helpers
    
    private func createDefaultRenderPipelineStates(){
        renderPipelineStates.updateValue(Test3MapPiplineState(), forKey: .Map)
        renderPipelineStates.updateValue(Test3BasicPiplineState(), forKey: .Basic)
        renderPipelineStates.updateValue(Test3MapMarchingSquaresPiplineState(), forKey: .MapMarchingSquares)
    }
}

protocol Test3RenderPipelineState {
    var name: String { get }
    var renderPipelineState: MTLRenderPipelineState! { get }
}

public struct Test3MapPiplineState: Test3RenderPipelineState {
    var name: String = "Map Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: Test3RenderPipelineDescriptorLibrary.shared.descriptor(.Map))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct Test3MapMarchingSquaresPiplineState: Test3RenderPipelineState {
    var name: String = "Map Marching Squares Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: Test3RenderPipelineDescriptorLibrary.shared.descriptor(.MapMarchingSquares))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct Test3BasicPiplineState: Test3RenderPipelineState {
    var name: String = "Basic Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: Test3RenderPipelineDescriptorLibrary.shared.descriptor(.Basic))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}
