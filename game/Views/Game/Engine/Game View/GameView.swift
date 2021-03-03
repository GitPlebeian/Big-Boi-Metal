//
//  GameView.swift
//  game
//
//  Created by Jackson Tubbs on 12/11/20.
//

import UIKit

class GameView: UIView {
    
    // MARK: Properties
    
    var engine:          Engine!
    var objects:         [Object]   = []
    
    // Updates
    var updateComplete:  Bool       = true
    
    // Window
    var height:          Float      = 0
    var width:           Float      = 0
    var didSetBounds:    Bool       = false
    override var bounds: CGRect {
        didSet {
            if didSetBounds == false {
                height = Float(bounds.height)
                width  = Float(bounds.width)
                didSetBounds = true
                self.engine = Engine()
                engine.clearColor = [Double(UIColor.background1.redValue),
                                     Double(UIColor.background1.greenValue),
                                     Double(UIColor.background1.blueValue)]
                engine.delegate = self
                setupViews()
            }
        }
    }
    
    // MARK: Views
    
    weak var debugView: DebugView!
    
    // MARK: Style Guide
    
    // MARK: Action
    
    // MARK: Helpers
    
    // Add Object
    func addObject(_ object: Object, layer: Int) {
        objects.append(object)
        engine.updateData()
    }
    
    // Wipe Data
    func wipeData() {
        objects = []
        engine.updateData()
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        // Engine
        addSubview(engine)
        engine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            engine.topAnchor.constraint(equalTo: topAnchor),
            engine.leadingAnchor.constraint(equalTo: leadingAnchor),
            engine.trailingAnchor.constraint(equalTo: trailingAnchor),
            engine.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Debug
        let debugView = DebugView()
        debugView.addSuperView(view: self)
        self.debugView = debugView
    }
}

extension GameView: EngineDelegate {
    
    // Update
    func update() {
        updateComplete = false
//        let start = DispatchTime.now()
        debugView.update {
            DispatchQueue.main.async {
//                let end = DispatchTime.now()
//                let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
//                let timeInterval = 1_000_000_000 / Double(nanoTime)
//                print("UPS: \(timeInterval)")
                self.engine.updateData()
                self.updateComplete = true
            }
        }
    }
}
