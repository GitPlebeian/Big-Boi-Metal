//
//  GameView1.swift
//  game
//
//  Created by Jackson Tubbs on 12/11/20.
//

import UIKit

protocol GameViewDelegate1: class {
    func update(_ completion: @escaping () -> Void)
}

class GameView1: UIView {
    
    // MARK: Properties
    
    // Delegate
    weak var delegate:   GameViewDelegate1?
    
    var engine:          Engine1!
    var objects:         [Object]   = []
    
    // Updates
    var updateComplete:  Bool       = true
    
    // Window
    var height:          Float      = 0
    var width:           Float      = 0
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        height = Float(frame.height)
        width  = Float(frame.width)
        self.engine = Engine1()
        engine.clearColor = [Double(UIColor.background1.redValue),
                             Double(UIColor.background1.greenValue),
                             Double(UIColor.background1.blueValue)]
        engine.delegate = self
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        print("Deinit Game View 1")
    }
    
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
    }
}

extension GameView1: EngineDelegate1 {
    
    // Update
    func update() {
        updateComplete = false
        
        delegate?.update {
            DispatchQueue.main.async {
                self.engine.updateData()
                self.updateComplete = true
            }
        }
    }
}
