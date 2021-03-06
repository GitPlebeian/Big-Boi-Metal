//
//  Test3ShaderLibrary.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import MetalKit

enum Test3VertexShaderTypes{
    case Map
    case Basic
}

enum Test3FragmentShaderTypes {
    case Map
    case Basic
}

class Test3ShaderLibrary {
    
    // MARK: Shared
    
    static let Shared = Test3ShaderLibrary()
    
    public var defaultLibrary: MTLLibrary!
    
    private var vertexShaders: [Test3VertexShaderTypes: Test3Shader] = [:]
    private  var fragmentShaders: [Test3FragmentShaderTypes: Test3Shader] = [:]
    
    // MARK: Init
    
    init() {
        defaultLibrary = GraphicsDevice.Device.makeDefaultLibrary()
        createDefaultShaders()
    }
    
    // MARK: Helpers
    
    private func createDefaultShaders() {
        //Vertex Shaders
        vertexShaders.updateValue(Test3Basic_VertexShader(library: defaultLibrary), forKey: .Basic)
        vertexShaders.updateValue(Test3Map_VertexShader(library: defaultLibrary), forKey: .Map)
        
        //Fragment Shaders
        fragmentShaders.updateValue(Test3Basic_FragmentShader(library: defaultLibrary), forKey: .Basic)
        fragmentShaders.updateValue(Test3Map_FragmentShader(library: defaultLibrary), forKey: .Map)
    }
    
    public func vertex(_ vertexShaderType: Test3VertexShaderTypes) -> MTLFunction {
        return vertexShaders[vertexShaderType]!.function
    }
    
    public func fragment(_ fragmentShaderType: Test3FragmentShaderTypes) -> MTLFunction {
        return fragmentShaders[fragmentShaderType]!.function
    }
    
}

protocol Test3Shader {
    var name: String { get }
    var functionName: String { get }
    var function: MTLFunction! { get }
}

public struct Test3Basic_VertexShader: Test3Shader {
    public var name: String = "Basic Vertex Shader"
    public var functionName: String = "test3_vertex_basic"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Test3Basic_FragmentShader: Test3Shader {
    public var name: String = "Basic Fragment Shader"
    public var functionName: String = "test3_fragment_basic"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Test3Map_VertexShader: Test3Shader {
    public var name: String = "Map Vertex Shader"
    public var functionName: String = "test3_vertex_map"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}

public struct Test3Map_FragmentShader: Test3Shader {
    public var name: String = "Map Fragment Shader"
    public var functionName: String = "test3_fragment_map"
    public var function: MTLFunction!
    init(library: MTLLibrary){
        function = library.makeFunction(name: functionName)
        function?.label = name
    }
}
