//
//  Test3ShaderLibrary.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import MetalKit

enum VertexShaderTypes {
    case Map
    case MapMarchingSquares
    case Basic
    case Grid
    case Texture
}

enum FragmentShaderTypes {
    case Map
    case MapMarchingSquares
    case Basic
    case Grid
    case Texture
}

class ShaderLibrary {
    
    // MARK: Shared
    
    static let Shared = ShaderLibrary()
    
    public var defaultLibrary: MTLLibrary!
    
    private var vertexShaders: [VertexShaderTypes: Shader] = [:]
    private  var fragmentShaders: [FragmentShaderTypes: Shader] = [:]
    
    // MARK: Init
    
    init() {
        defaultLibrary = GraphicsDevice.Device.makeDefaultLibrary()
        createDefaultShaders()
    }
    
    // MARK: Helpers
    
    private func createDefaultShaders() {
        //Vertex Shaders
        vertexShaders.updateValue(Basic_VertexShader(library: defaultLibrary), forKey: .Basic)
        vertexShaders.updateValue(Map_VertexShader(library: defaultLibrary), forKey: .Map)
        vertexShaders.updateValue(Map_VertexShaderMarchingSquares(library: defaultLibrary), forKey: .MapMarchingSquares)
        vertexShaders.updateValue(Grid_VertexShader(library: defaultLibrary), forKey: .Grid)
        vertexShaders.updateValue(Texture_VertexShader(library: defaultLibrary), forKey: .Texture)
        
        //Fragment Shaders
        fragmentShaders.updateValue(Basic_FragmentShader(library: defaultLibrary), forKey: .Basic)
        fragmentShaders.updateValue(Map_FragmentShader(library: defaultLibrary), forKey: .Map)
        fragmentShaders.updateValue(Map_FragmentShaderMarchingSquares(library: defaultLibrary), forKey: .MapMarchingSquares)
        fragmentShaders.updateValue(Grid_FragmentShader(library: defaultLibrary), forKey: .Grid)
        fragmentShaders.updateValue(Texture_FragmentShader(library: defaultLibrary), forKey: .Texture)
        
    }
    
    public func vertex(_ vertexShaderType: VertexShaderTypes) -> MTLFunction {
        return vertexShaders[vertexShaderType]!.function
    }
    
    public func fragment(_ fragmentShaderType: FragmentShaderTypes) -> MTLFunction {
        return fragmentShaders[fragmentShaderType]!.function
    }
    
}

protocol Shader {
    var name: String { get }
    var functionName: String { get }
    var function: MTLFunction! { get }
}

public struct Basic_VertexShader: Shader {
    public var name: String = "Basic Vertex Shader"
    public var functionName: String = "test3_vertex_basic"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Basic_FragmentShader: Shader {
    public var name: String = "Basic Fragment Shader"
    public var functionName: String = "test3_fragment_basic"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Map_VertexShader: Shader {
    public var name: String = "Map Vertex Shader"
    public var functionName: String = "test3_vertex_map"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Map_FragmentShader: Shader {
    public var name: String = "Map Fragment Shader"
    public var functionName: String = "test3_fragment_map"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Map_VertexShaderMarchingSquares: Shader {
    public var name: String = "Map Vertex Shader Marching Squares"
    public var functionName: String = "test3_vertex_map_marching_squares"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Map_FragmentShaderMarchingSquares: Shader {
    public var name: String = "Map Fragment Shader Marching Squares"
    public var functionName: String = "test3_fragment_map_marching_squares"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Grid_VertexShader: Shader {
    public var name: String = "Grid Vertex Shader"
    public var functionName: String = "test3_vertex_grid"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Grid_FragmentShader: Shader {
    public var name: String = "Grid Fragment Shader"
    public var functionName: String = "test3_fragment_grid"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Texture_VertexShader: Shader {
    public var name: String = "Texture Vertex Shader"
    public var functionName: String = "test3_vertex_texture"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Texture_FragmentShader: Shader {
    public var name: String = "Texture Fragment Shader"
    public var functionName: String = "test3_fragment_texture"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}
