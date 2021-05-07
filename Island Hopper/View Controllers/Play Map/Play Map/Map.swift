//
//  Map.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/12/21.
//

import UIKit

class Map {
    
    // MARK: Properties
    
    let width: Int
    let height: Int
    let tiles: [TileType]
    
    // MARK: Init
    
    // MARK: Deinit
    
    deinit {
        print("Map DEINIT")
    }
    
    init() {
        self.width = 0
        self.height = 0
        self.tiles = []
    }
    
    init(mapSave: MapSave) {
        self.width = mapSave.width
        self.height = mapSave.height
        var tiles: [TileType] = []
        for type in mapSave.types {
            tiles.append(TileType.init(rawValue: type)!)
        }
        self.tiles = tiles
    }
}
