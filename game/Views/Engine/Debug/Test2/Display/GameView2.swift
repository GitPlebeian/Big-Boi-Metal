import MetalKit

class GameView2: MTKView {
    
    
    var renderer: Renderer!
    
    init(frame: CGRect) {
        
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        
        Engine.Ignite(device: device!)
        
        self.clearColor = Preferences.ClearColor
        
        self.colorPixelFormat = Preferences.MainPixelFormat
        
        self.renderer = Renderer()
        
        self.delegate = renderer
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Mouse Input
    
    //Keyboard Input
    
}

