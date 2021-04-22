//
//  MapLayer.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/12/21.
//

import UIKit

class MapLayer: RenderLayer {
    
    var map: Map
    
    init(map: Map) {
        self.map = map
        super.init()
        
        
    }
    
    override func setPipelineState() {
//        encoder
    }
    
    // Render
    
    override func render(_ encoder: MTLRenderCommandEncoder) {
        
        encoder.setRenderPipelineState(pipelineState)
    }
    
    // MARK: Public
    
    // MARK: Private
    
    //
}
