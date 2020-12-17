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
    var objects:         [Object] = []
    
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
                engine = Engine(height: height, width: width)
                engine.delegate = self
                setupViews()
            }
        }
    }
    
    // MARK: Gesture
    
    weak var tapGesture: UITapGestureRecognizer!
    
    // MARK: Style Guide
    
    // MARK: Action
    
    // Tapped
    @objc private func tapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
//        let position = FloatPoint(tapGesture.location(in: self))
        
    }
    
    // MARK: Helpers
    
    func addObject(_ object: Object, layer: Int) {
        objects.append(object)
        engine.updateData()
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        engine.layoutRenderer(superView: self)
        
        // Tap Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
        
        var playerShip = PlayerShip()
        playerShip.transform.x = 100
        playerShip.transform.y = height / 2
        playerShip.scaleShape(scale: 50)
        addObject(playerShip, layer: 0)
    }
}

extension GameView: EngineDelegate {
    
}
