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
    let step: UInt64
    
    init(player: UInt64,
         gameUUID: String,
         moves: [PlayerMove] = [],
         step: UInt64) {
        self.player = player
        self.gameUUID = gameUUID
        self.moves = moves
        self.step = step
    }
    
    enum CodingKeys: String, CodingKey {
        case player   = "Player"
        case gameUUID = "GameUUID"
        case moves    = "Moves"
        case step     = "Step"
    }
}

struct PlayerMove: Codable {
    let entityID: EntityID
    let cordX:    UInt64
    let cordY:    UInt64
    
    enum CodingKeys: String, CodingKey {
        case entityID = "ID"
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
    private var previousSubmittedMoves: [PlayerMove] = []
    var nextMoves: ReceivedMoves?
    
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

//        print("Getting Moves Bundle: \(controller.serverStep). Moves Count: \(queuedMoves.count)")
        return MovesBundle(player: UInt64(controller.currentPlayer),
                           gameUUID: controller.gameUUID,
                           moves: queuedMoves,
                           step: UInt64(controller.serverStep))
    }
    
    // Get Previous Queued Moves
    func getPreviousQueuedMoves() -> MovesBundle {
        return MovesBundle(player: UInt64(controller.currentPlayer),
                           gameUUID: controller.gameUUID,
                           moves: previousSubmittedMoves,
                           step: UInt64(controller.serverStep - 1))
    }
    
    // Clear Queue
    func clearQueue() {
        self.previousSubmittedMoves = queuedMoves
        self.queuedMoves = []
    }
}
