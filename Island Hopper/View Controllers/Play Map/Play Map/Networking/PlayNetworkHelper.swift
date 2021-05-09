//
//  PlayNetworkHelper.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/7/21.
//

import Foundation
import Network

extension PlayNetwork {
    
    
    // Handle Waiting For Players
    func handleWaitingForPlayers() {
        self.controller.alertController.waitingForPlayers()
    }
    
    // Start Game
    func handleStartGame(data: Data) {
        self.controller.alertController.dismissAlerts()
        let numData = data.subdata(in: 0..<8)
        let num: UInt64 = numData.withUnsafeBytes {
            pointer in
            return pointer.load(as: UInt64.self)
        }
        let gameUUID = String(decoding: data.subdata(in: 8..<data.count), as: UTF8.self)
        controller.gameUUID = gameUUID
        controller.currentPlayer = Int(num)
        sendMoves(bundle: MovesBundle(player: UInt64(controller.currentPlayer),
                                      gameUUID: controller.gameUUID,
                                      moves: []))
    }
    
    // Send Moves
    func sendMoves(bundle: MovesBundle) {
        do {
            controller.orderQueue.clearQueue()
            var data = getDataForOutType(type: .SubmitMoves)
            let moveData = try JSONEncoder().encode(bundle)
            data.append(moveData)
            sendUDP(data)
        } catch let e {
            print("Error:  💩💩💩: \(e)")
        }
    }
    
    // Handle Player Moves
    func handlePlayerMoves(data: Data) {
        let string = String(decoding: data, as: UTF8.self)
        do {
            let moves = try JSONDecoder().decode(ReceivedMoves.self, from: data)
            self.controller.stepGame(receivedMoves: moves)
        } catch let e {
            print("Error:  💩💩💩: \(e)")
            print("\n\n\(string)")
        }
    }
}
