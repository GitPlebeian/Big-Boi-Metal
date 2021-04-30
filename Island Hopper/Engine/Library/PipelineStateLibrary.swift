
import MetalKit

enum RenderPipelineStateTypes {
    case Map
    case Basic
    case MapMarchingSquares
    case Grid
    case Texture
    case MapMovable
}

class RenderPipelineStateLibrary {
    
    // MARK: Shared
    
    static let shared = RenderPipelineStateLibrary()
    
    // MARK: Properties
    
    private var renderPipelineStates: [RenderPipelineStateTypes: RenderPipelineState] = [:]
    
    // MARK: Init
    
    init() {
        createDefaultRenderPipelineStates()
    }
    
    func pipelineState(_ renderPipelineStateType: RenderPipelineStateTypes) -> MTLRenderPipelineState {
        return (renderPipelineStates[renderPipelineStateType]?.renderPipelineState)!
    }
    
    // MARK: Helpers
    
    private func createDefaultRenderPipelineStates() {
        renderPipelineStates.updateValue(MapPiplineState(), forKey: .Map)
        renderPipelineStates.updateValue(BasicPiplineState(), forKey: .Basic)
        renderPipelineStates.updateValue(MapMarchingSquaresPiplineState(), forKey: .MapMarchingSquares)
        renderPipelineStates.updateValue(GridPiplineState(), forKey: .Grid)
        renderPipelineStates.updateValue(TexturePiplineState(), forKey: .Texture)
        renderPipelineStates.updateValue(MapMovablePiplineState(), forKey: .MapMovable)
    }
}

protocol RenderPipelineState {
    var name: String { get }
    var renderPipelineState: MTLRenderPipelineState! { get }
}

public struct MapPiplineState: RenderPipelineState {
    var name: String = "Map Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.shared.descriptor(.Map))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct MapMarchingSquaresPiplineState: RenderPipelineState {
    var name: String = "Map Marching Squares Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.shared.descriptor(.MapMarchingSquares))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct BasicPiplineState: RenderPipelineState {
    var name: String = "Basic Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.shared.descriptor(.Basic))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct GridPiplineState: RenderPipelineState {
    var name: String = "Grid Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.shared.descriptor(.Grid))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct TexturePiplineState: RenderPipelineState {
    var name: String = "Texture Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.shared.descriptor(.Texture))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct MapMovablePiplineState: RenderPipelineState {
    var name: String = "Map Movable Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    init() {
        do{
            renderPipelineState = try GraphicsDevice.Device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.shared.descriptor(.MapMovable))
        }catch let error as NSError {
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}
