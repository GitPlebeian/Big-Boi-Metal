//
//  Entity.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/6/21.
//

import Foundation

class Entity {
    
    // MARK: Static
    
    // Get Entity Type For ID
    static func getEntityTypeForID(id: EntityID) -> Entity {
        switch id {
        case .Warrior:
            return WarriorEntity(textureCords: [16, 512], width: 16, height: 16)
        }
    }
    
    // MARK: Properties
    
    var position: IntCordinate
    var textureCords: [Float]
    var width: Int // In Pixels
    var height: Int // In Pixels
    var id: EntityID!
    
    // MARK: Blocks
    
    var update: ((PlayController) -> Void)!
    
    // MARK: Init
    
    init(position: IntCordinate = IntCordinate(),
         textureCords: [Float],
         width: Int,
         height: Int) {
        
        self.position = position
        self.textureCords = textureCords
        self.width = width
        self.height = height
        
        setUpdate()
    }
    
    // MARK: Deinit
    
    deinit {
        print("Entity DEINIT")
    }
    
    // MARK: Public
    
    func setUpdate() {}
}

enum EntityID: UInt64, Codable {
    case Warrior = 0
}

