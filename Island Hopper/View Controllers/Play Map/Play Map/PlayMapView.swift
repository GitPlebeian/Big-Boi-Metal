//
//  PlayMapView.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/12/21.
//

import UIKit

class PlayMapView: UIView {

    // MARK: Properties
    
    let mapURL: URL
    var controller: PlayController!
    
    private var didSetBounds: Bool = false
    override var bounds: CGRect {
        didSet {
            if !didSetBounds {
                didSetBounds = true
                // Works Like My Init
                setupViews()
                setupController()
                setupControllerDependents()
            }
        }
    }
    
    // MARK: Subviews
    
    weak var engine:                Engine!
    weak var engineTouchController: EngineTouchController!
    
    // MARK: Init
    
    init(mapURL: URL) {
        self.mapURL = mapURL
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    // MARK: Actions
    
    // MARK: Public
    
    // MARK: Private
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        let engine = Engine(clearColor: .mapDarkSea)
        engine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(engine)
        NSLayoutConstraint.activate([
            engine.topAnchor.constraint(equalTo: topAnchor),
            engine.leadingAnchor.constraint(equalTo: leadingAnchor),
            engine.trailingAnchor.constraint(equalTo: trailingAnchor),
            engine.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.engine = engine
        
        let engineTouchController = EngineTouchController()
        engineTouchController.translatesAutoresizingMaskIntoConstraints = false
        addSubview(engineTouchController)
        NSLayoutConstraint.activate([
            engineTouchController.topAnchor.constraint(equalTo: topAnchor),
            engineTouchController.leadingAnchor.constraint(equalTo: leadingAnchor),
            engineTouchController.trailingAnchor.constraint(equalTo: trailingAnchor),
            engineTouchController.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.engineTouchController = engineTouchController
    }
    
    // MARK: Setup Controller
    
    private func setupController() {
        self.controller = PlayController(engine: engine,
                                         touchController: engineTouchController,
                                         mapURL: mapURL,
                                         playMapView: self)
        engineTouchController.delegate = controller
    }
    
    // MARK: Setup Controller Dependents
     
    private func setupControllerDependents() {
        
    }
}
