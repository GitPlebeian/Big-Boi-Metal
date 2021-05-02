//
//  PlayController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/12/21.
//

import UIKit

class PlayController {
    
    var map: Map!
    
    weak var engine: Engine!
    weak var touchController: EngineTouchController!
    
    var mapLayer: MapLayer!
    var gridLayer: GridLayer!
    
    // MARK: Init
    
    init(engine: Engine,
         touchController: EngineTouchController,
         mapURL: URL) {
        
        self.engine = engine
        self.touchController = touchController
        self.map = loadMap(url: mapURL)
        self.mapLayer = MapLayer(map: self.map,
                                 touchController: touchController)
        self.gridLayer = GridLayer(map: mapLayer,
                                   touchController: touchController)
        engine.addLayer(mapLayer, atLayer: 0)
    }
    
    // MARK: Public
    
    // MARK: Private
    
    // Load Map
    private func loadMap(url: URL) -> Map {
        do {
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            let mapSave = try jsonDecoder.decode(MapSave.self, from: data)
            return Map(mapSave: mapSave)
        } catch {
            print("Unable To Decode Map From URL")
            return Map()
        }
    }
}

extension PlayController: EngineTouchControllerDelegate {
    func tapped(location: FloatPoint) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
}
