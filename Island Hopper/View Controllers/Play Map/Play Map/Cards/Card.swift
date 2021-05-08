//
//  Card.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/4/21.
//

import UIKit

class Card {
    
    weak var entityBeingPlaced: Entity?
    weak var controller: PlayController!
    
    var startedPlacingBlock: ((CGPoint) -> Void)!
    var placingPannedBlock: ((CGPoint) -> Void)!
    var placedCard: ((CGPoint) -> Void)!
    var placingCancelled: (() -> Void)!
    
    init(controller: PlayController) {
        self.controller = controller
        setPlacingBlock()
        setPannedBlock()
        setPlacedCard()
        setPlacingCancelled()
    }
    
    // MARK: Deinit
    
    deinit {
        print("Card DEINIT")
    }
    
    // Setup Placin Block
    func setPlacingBlock() {}
    
    // Setup Panned Block
    func setPannedBlock() {}
    
    // Set Placed Card
    func setPlacedCard() {}
    
    // Set Placing Cancelled
    func setPlacingCancelled() {}
}