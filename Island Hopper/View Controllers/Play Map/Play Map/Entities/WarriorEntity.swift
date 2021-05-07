//
//  WarriorEntity.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/6/21.
//

import Foundation

class WarriorEntity: Entity {
    
    // MARK: Properties
    
    // Set Update
    
    // MARK: Deinit
    
    deinit {
        print("Warrior Entity DEINIT")
    }
    
    override func setUpdate() {
        self.update = { [weak self] controller in
            
            guard let self = self else {return}
            
            self.position.y += 1
            
            if let currentTile = controller.mapLocationHelper.getWholeTypeForLocation(cord: self.position) {
                if currentTile == .darkSea {
                    controller.entityController.removeEntity(entity: self)
                    return
                }
            }
            // Off Grid
            if controller.mapLocationHelper.onMapCordinates(cord: self.position) == false {
                controller.entityController.removeEntity(entity: self)
                return
            }
        }
    }
}
