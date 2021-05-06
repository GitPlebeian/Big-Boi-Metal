//
//  Test3ShaderLibrary.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import MetalKit

enum VertexShaderTypes {
    case Map
    case MapMovable
    case MapMarchingSquares
    case Basic
    case Grid
    case Texture
    case CelledTexture
}

enum FragmentShaderTypes {
    case Map
    case MapMovable
    case MapMarchingSquares
    case Basic
    case Grid
    case Texture
    case CelledTexture
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
        vertexShaders.updateValue(MapMovableTexture_VertexShader(library: defaultLibrary), forKey: .MapMovable)
        vertexShaders.updateValue(CelledTexture_VertexShader(library: defaultLibrary), forKey: .CelledTexture)
        
        //Fragment Shaders
        fragmentShaders.updateValue(Basic_FragmentShader(library: defaultLibrary), forKey: .Basic)
        fragmentShaders.updateValue(Map_FragmentShader(library: defaultLibrary), forKey: .Map)
        fragmentShaders.updateValue(Map_FragmentShaderMarchingSquares(library: defaultLibrary), forKey: .MapMarchingSquares)
        fragmentShaders.updateValue(Grid_FragmentShader(library: defaultLibrary), forKey: .Grid)
        fragmentShaders.updateValue(Texture_FragmentShader(library: defaultLibrary), forKey: .Texture)
        fragmentShaders.updateValue(MapMovableTexture_FragmentShader(library: defaultLibrary), forKey: .MapMovable)
        fragmentShaders.updateValue(CelledTexture_FragmentShader(library: defaultLibrary), forKey: .CelledTexture)
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
    public var functionName: String = "basic_vertex"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Basic_FragmentShader: Shader {
    public var name: String = "Basic Fragment Shader"
    public var functionName: String = "basic_fragment"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Map_VertexShader: Shader {
    public var name: String = "Map Vertex Shader"
    public var functionName: String = "map_vertex"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Map_FragmentShader: Shader {
    public var name: String = "Map Fragment Shader"
    public var functionName: String = "map_fragment"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Map_VertexShaderMarchingSquares: Shader {
    public var name: String = "Map Vertex Shader Marching Squares"
    public var functionName: String = "map_marching_squares_vertex"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Map_FragmentShaderMarchingSquares: Shader {
    public var name: String = "Map Fragment Shader Marching Squares"
    public var functionName: String = "map_marching_squares_fragment"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Grid_VertexShader: Shader {
    public var name: String = "Grid Vertex Shader"
    public var functionName: String = "grid_vertex"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Grid_FragmentShader: Shader {
    public var name: String = "Grid Fragment Shader"
    public var functionName: String = "grid_fragment"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Texture_VertexShader: Shader {
    public var name: String = "Texture Vertex Shader"
    public var functionName: String = "texture_vertex"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Texture_FragmentShader: Shader {
    public var name: String = "Texture Fragment Shader"
    public var functionName: String = "texture_fragment"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct MapMovableTexture_VertexShader: Shader {
    public var name: String = "Texture Vertex Shader"
    public var functionName: String = "map_movable_texture_vertex"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct MapMovableTexture_FragmentShader: Shader {
    public var name: String = "Texture Fragment Shader"
    public var functionName: String = "map_movable_texture_fragment"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct CelledTexture_VertexShader: Shader {
    public var name: String = "Celled Texture Vertex Shader"
    public var functionName: String = "celled_texture_vertex"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct CelledTexture_FragmentShader: Shader {
    public var name: String = "Celled Texture Fragment Shader"
    public var functionName: String = "celled_texture_fragment"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}
