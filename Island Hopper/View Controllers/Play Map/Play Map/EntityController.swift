//
//  EntityController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/6/21.
//

import Foundation

class EntityController {
    
    // MARK: Properties
    
    weak var controller: PlayController!
    
    private var entities: [Entity] = []
    
    // MARK: Init
    
    init(controller: PlayController) {
        self.controller = controller
    }
    
    // MARK: Deinit
    
    deinit {
        print("Entity Controller DEINIT")
    }
    
    // MARK: Public
    
    // Add Entity
    func addEntity(entity: Entity) {
        entities.append(entity)
        controller.celledTextureLayer.addEntity(entity: entity)
    }
    
    // Remove Entity
    func removeEntity(entity: Entity) {
        for (index, e) in entities.enumerated() {
            if entity === e {
                entities.remove(at: index)
            }
        }
        controller.celledTextureLayer.removeEntity(entity: entity)
    }
    
    // Update
    func update() {
        for entity in entities {
            entity.update(controller)
        }
    }
    
    // MARK: Private
    
    
}
