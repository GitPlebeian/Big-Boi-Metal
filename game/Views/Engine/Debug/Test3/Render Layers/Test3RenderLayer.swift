//
//  Test3Layer.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import UIKit

class Test3RenderLayer {
    
    var pipelineState: MTLRenderPipelineState!
    var isCustomPass:  Bool = false
    
    init() {
        setPipelineState()
    }
    
    // Set Pipeline State
    func setPipelineState() {}
    
    // Update
    func update() {}
    
    // Render
    func render(_ encoder: MTLRenderCommandEncoder) {}
    
    // Render
    func render(_ commandBuffer: MTLCommandBuffer, _ drawableTexture: MTLTexture) {}
}
