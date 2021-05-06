//
//  EntityPlacer.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/5/21.
//

import UIKit

class EntityPlacer {
    
    // MARK: Properties
    
    weak var controller: PlayController!
    
    var placingEntity: Entity? {
        didSet {
            guard let entity = placingEntity else {return}
            controller.celledTextureLayer.addEntity(entity: entity)
        }
    }
    
    // MARK: Init
    
    init(controller: PlayController) {
        self.controller = controller
    }
    
    // MARK: Public
    
    func startedPlacing(entity: Entity) {
        placingEntity = entity
    }
    
    func cancelledPlacing() {
        controller.celledTextureLayer.removeEntity(entity: placingEntity!)
        placingEntity = nil
    }
    
    func placedCard() {
        placingEntity = nil
    }
    
    func pannedTo(location: CGPoint) {
        let cord = controller.mapLocationHelper.getCellForLocation(location: location)
        placingEntity?.position = cord
    }
    
    // MARK: Helpers
}
