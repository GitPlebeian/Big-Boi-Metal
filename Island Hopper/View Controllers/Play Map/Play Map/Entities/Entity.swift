//
//  Entity.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/6/21.
//

import Foundation

class Entity {
    
    // MARK: Properties
    
    var position: IntCordinate
    var textureCords: [Float]
    var width: Int // In Pixels
    var height: Int // In Pixels
    
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
