import UIKit

class RenderLayer {
    
    var pipelineState: MTLRenderPipelineState!
    
    init() {
        setPipelineState()
    }
    
    // Set Pipeline State
    func setPipelineState() {}
    
    // Update
    func update() {}
    
    // setPiple
    
    // Render
    func render(_ encoder: MTLRenderCommandEncoder) {}
}
