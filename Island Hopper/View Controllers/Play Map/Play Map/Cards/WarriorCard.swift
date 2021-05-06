//
//  WarriorCard.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/6/21.
//

import UIKit

class WarriorCard: Card {
    
    // Set Placing Block
    override func setPlacingBlock(){
        self.startedPlacingBlock = {[weak self] location in
            guard let self = self else {return}
            let cord = self.controller.mapLocationHelper.getCellForLocation(location: location)
            let entity = Entity(position: cord, textureCords: [16, 512], width: 16, height: 16)
            self.controller.gridLayer.enabled = true
            self.controller.entityPlacer.startedPlacing(entity: entity)
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
        }
    }
    
    // Set Placing Cancelled
    override func setPlacingCancelled() {
        self.placingCancelled = {
            self.controller.entityPlacer.cancelledPlacing()
        }
    }
}
