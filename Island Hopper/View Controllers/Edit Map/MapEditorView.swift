//
//  GameView3.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import UIKit

class MapEditorView: UIView {
    
    // MARK: Properties
    
    var editMapController:     MapEditorController!

    
    // MARK: Views
    
    weak var engine:                Engine!
    weak var engineTouchController: EngineTouchController!
    weak var chunkEditor:           ChunkEditorView!
    
    // MARK: Constraints
    
    var chunkEditorWidthConstraint:  NSLayoutConstraint!
    var chunkEditorHeightConstraint: NSLayoutConstraint!
    
    // MARK: Init
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setupController()
        setupControllerDependents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        print("Map Editor View Deinit")
    }
    
    // MARK: Helpers
    
    // Add Object
    func addLayer(_ layer: RenderLayer, atLayer: Int) {
        engine.addLayer(layer, atLayer: atLayer)
    }
    
    // Wipe Data
    func wipeData() {
        engine.wipeData()
    }
    
    // Toggle Chunk Editor
    func toggleChunkEditor() {
        if chunkEditor.open { // Close it
            chunkEditorWidthConstraint.isActive = false
            chunkEditorWidthConstraint = chunkEditor.widthAnchor.constraint(equalToConstant: 44)
            chunkEditorWidthConstraint.priority = .defaultHigh
            chunkEditorWidthConstraint.isActive = true

            chunkEditorHeightConstraint.isActive = false
            chunkEditorHeightConstraint = chunkEditor.heightAnchor.constraint(equalToConstant: 44)
            chunkEditorHeightConstraint.priority = .defaultHigh
            chunkEditorHeightConstraint.isActive = true

            chunkEditor.closeView()
        } else { // Open It
            chunkEditorWidthConstraint.isActive = false
            chunkEditorWidthConstraint = chunkEditor.widthAnchor.constraint(equalToConstant: 250)
            chunkEditorWidthConstraint.isActive = true

            chunkEditorHeightConstraint.isActive = false
            chunkEditorHeightConstraint = chunkEditor.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
            chunkEditorHeightConstraint.isActive = true

            chunkEditor.openView()
        }
        chunkEditor.open = !chunkEditor.open
    }
    
    // MARK: Setup Views
    
    private func setupViews() {

        let engine = Engine(clearColor: .mapSuperDeepWater)
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
        let editMapController = MapEditorController(engine: engine,
                                                    touchController: engineTouchController)
        self.editMapController = editMapController
    }
    
    // MARK: Setup Controller Dependents
    
    private func setupControllerDependents() {
        
        // Chunk Editor
        let chunkEditor = ChunkEditorView(map: editMapController.map,
                                          editorView: self)
        chunkEditor.backgroundColor = .background2
        chunkEditor.layer.cornerRadius = 16
        chunkEditor.layer.masksToBounds = true
        chunkEditor.translatesAutoresizingMaskIntoConstraints = false
        self.chunkEditorWidthConstraint = chunkEditor.widthAnchor.constraint(equalToConstant: 44)
        self.chunkEditorHeightConstraint = chunkEditor.heightAnchor.constraint(equalToConstant: 44)
        addSubview(chunkEditor)
        NSLayoutConstraint.activate([
            chunkEditor.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            chunkEditor.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chunkEditorWidthConstraint,
            chunkEditorHeightConstraint
        ])
        self.chunkEditor = chunkEditor
    }
}
