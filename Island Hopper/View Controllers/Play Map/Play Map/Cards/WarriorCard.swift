//
//  WarriorCard.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/6/21.
//

import UIKit

class WarriorCard: Card {
    
    // MARK: Deinit
    
    deinit {
        print("Warrior Card DEINIT")
    }
    
    // Set Placing Block
    override func setPlacingBlock(){
        self.startedPlacingBlock = { location in
            let cord = self.controller.mapLocationHelper.getCellForLocation(location: location)
            let entity = WarriorEntity(position: cord, textureCords: [16, 512], width: 16, height: 16)
            self.controller.gridLayer.enabled = true
            self.controller.entityPlacer.startedPlacing(entity: entity)
            self.entityBeingPlaced = entity
        }
    }
    
    // Set Panned Block
    override func setPannedBlock() {
        self.placingPannedBlock = { location in
            self.controller.entityPlacer.pannedTo(location: location)
        }
    }
    
    // Set Placed Card
    override func setPlacedCard() {
        self.placedCard = { location in
            self.controller.gridLayer.enabled = false
            self.controller.entityPlacer.placedCard()
            self.controller.entityController.addEntity(entity: self.entityBeingPlaced!)
            self.entityBeingPlaced = nil
        }
    }
    
    // Set Placing Cancelled
    override func setPlacingCancelled() {
        self.placingCancelled = {
            self.controller.entityPlacer.cancelledPlacing()
            self.entityBeingPlaced = nil
        }
    }
}
