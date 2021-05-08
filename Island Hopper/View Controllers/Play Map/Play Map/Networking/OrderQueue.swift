//
//  OrderQueue.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/7/21.
//

import Foundation

struct MovesBundle: Codable {
    let player: UInt64
    let gameUUID: String
    let moves: [PlayerMove]
    
    enum CodingKeys: String, CodingKey {
        case player   = "Player"
        case gameUUID = "GameUUID"
        case moves    = "Moves"
    }
}

struct PlayerMove: Codable {
    let entityID: EntityID
    let cordX:    UInt64
    let cordY:    UInt64
    
    enum CodingKeys: String, CodingKey {
        case entityID = "EntityID"
        case cordX    = "CordX"
        case cordY    = "CordY"
    }
}

struct ReceivedMoves: Codable {
    let playerOneMoves: MovesBundle
    let playerTwoMoves: MovesBundle
    let step: UInt64
    
    enum CodingKeys: String, CodingKey {
        case playerOneMoves = "PlayerOneMoves"
        case playerTwoMoves = "PlayerTwoMoves"
        case step           = "Step"
    }
}

class OrderQueue {
    
    // MARK: Properties
    
    weak var controller: PlayController!
    
    private var queuedMoves: [PlayerMove] = []
    
    // MARK: Init
    
    init(controller: PlayController) {
        self.controller = controller
    }
    
    // MARK: Public
    
    // Add Entity
    func addEntity(entity: Entity) {
        let move = PlayerMove(entityID: entity.id,
                              cordX: UInt64(entity.position.x),
                              cordY: UInt64(entity.position.y))
        queuedMoves.append(move)
    }
    
    // Get Queued Moves
    func getMovesBundle() -> MovesBundle {
        return MovesBundle(player: UInt64(controller.currentPlayer),
                           gameUUID: controller.gameUUID,
                           moves: queuedMoves)
    }
}
