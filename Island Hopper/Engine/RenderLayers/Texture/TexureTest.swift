//
//  Test3TexureTest.swift
//  game
//
//  Created by Jackson Tubbs on 3/27/21.
//

import UIKit
import MetalKit

class TextureTest: RenderLayer {
    
    // MARK: Properties
    
    // MARK: Init
    
    override init() {
        
        super.init()
    }
    
    // MARK: Rendering
    
    override func setPipelineState() {
//        self.pipelineState = Test3RenderPipelineStateLibrary.shared.pipelineState(.Texture)
    }
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        
        let vertices: [Float] = [-0.2, 0.2, 0.2, -0.2, -0.2, -0.2,
                                 0.2, 0.2, 0.2, -0.2, -0.2, 0.2]
        let textureCords: [Float] = [0, 0, 1, 1, 0, 1,
                                     1, 0, 1, 1, 0, 0]
        
        encoder.setRenderPipelineState(pipelineState)
        
        let buffer = GraphicsDevice.Device.makeBuffer(bytes: vertices, length: vertices.count * 4, options: [])
        let textureBuffer = GraphicsDevice.Device.makeBuffer(bytes: textureCords, length: textureCords.count * 4, options: [])
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter             = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.magFilter             = MTLSamplerMinMagFilter.nearest
        samplerDescriptor.mipFilter             = MTLSamplerMipFilter.nearest
        samplerDescriptor.maxAnisotropy         = 1
        samplerDescriptor.sAddressMode          = MTLSamplerAddressMode.clampToEdge
        samplerDescriptor.tAddressMode          = MTLSamplerAddressMode.clampToEdge
        samplerDescriptor.rAddressMode          = MTLSamplerAddressMode.clampToEdge
        samplerDescriptor.normalizedCoordinates = true
        samplerDescriptor.lodMinClamp           = 0
        samplerDescriptor.lodMaxClamp           = .greatestFiniteMagnitude
        
        let sampler = GraphicsDevice.Device.makeSamplerState(descriptor: samplerDescriptor)!
        
        let image = UIImage(named: "testSprite3")!

        let imageRef = image.cgImage!

        let width = imageRef.width
        let height = imageRef.height

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        
        let region = MTLRegionMake2D(0, 0, width, height)

        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        guard let texture = GraphicsDevice.Device.makeTexture(descriptor: textureDescriptor) else {
            print("Dumb Stuff")
            return
        }
        
        texture.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: width * 4)
        
        encoder.setVertexBuffer(buffer, offset: 0, index: 0)
        encoder.setVertexBuffer(textureBuffer, offset: 0, index: 1)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentSamplerState(sampler, index: 0)
        
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count / 2)
    }
    
    // MARK: Public
    
    // MARK: Helpers
}
