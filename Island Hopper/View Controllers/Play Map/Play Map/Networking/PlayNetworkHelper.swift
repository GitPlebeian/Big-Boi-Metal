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
        hasReceivedGameStartData = true
        self.controller.alertController.dismissAlerts()
        let numData = data.subdata(in: 0..<8)
        let num: UInt64 = numData.withUnsafeBytes {
            pointer in
            return pointer.load(as: UInt64.self)
        }
        let gameUUID = String(decoding: data.subdata(in: 8..<data.count), as: UTF8.self)
        controller.gameUUID = gameUUID
        controller.currentPlayer = Int(num)
//        print("Handling Start Game. Step: \(controller.serverStep). Calling \"stepGame(nil)\"")
        controller.stepGame(receivedMoves: nil)
    }
    
    // Send Moves
    func sendMoves(bundle: MovesBundle) {
        do {
            controller.orderQueue.clearQueue()
            var data = getDataForOutType(type: .SubmitMoves)
            let moveData = try JSONEncoder().encode(bundle)
            data.append(moveData)
            sendUDP(data)
            print("SENT: Moves")
        } catch let e {
            print("Error:  💩💩💩: \(e)")
        }
    }
    
    // Handle Player Moves
    func handlePlayerMoves(data: Data) {
        let string = String(decoding: data, as: UTF8.self)
        do {
            let moves = try JSONDecoder().decode(ReceivedMoves.self, from: data)
            print("Received Moves: Step: \(moves.step)")
            if Int(moves.step) != controller.serverStep {
                print("Moves.Step !- Controller.ServerStep")
                return
            } else {
                self.expectedMovesTimer?.invalidate()
            }
            controller.orderQueue.nextMoves = moves
            
//            print("Handling Player Moves. Step: \(controller.serverStep). Moves.step: \(moves.step)")
            controller.stepGameIfApplicable()
        } catch let e {
            print("Error:  💩💩💩: \(e)")
            print("\n\n\(string)")
        }
    }
    
    // Request Game Start Data
    func requestGameStartData() {
        var data = getDataForOutType(type: .RequestGameStartData)
        let uuidData = uuid.data(using: .utf8)!
        data.append(uuidData)
        sendUDP(data)
        expectedRequestGameStartDataTimer?.invalidate()
        expectedRequestGameStartDataTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] timer in
            timer.invalidate()
            guard let self = self else {return}
            self.requestGameStartData()
        })
        RunLoop.main.add(expectedRequestGameStartDataTimer!, forMode: .common)
        print("SENT: Requesting Game Start Data")
    }
    
    // Handle Request Player Moves
    func handleRequestPlayerMoves() {
        print("Attempting to send previous moves")
        sendMoves(bundle: controller.orderQueue.getPreviousQueuedMoves())
    }
    
    // Request Moves From Server
    func requestPreviousMoves() {
        let dataStruct = GameUUIDUserUUID(playerUUID: uuid,
                                          gameUUID: controller.gameUUID)
        do {
            var data = getDataForOutType(type: .GetPreviousMoves)
            let structData = try JSONEncoder().encode(dataStruct)
            data.append(structData)
            sendUDP(data)
            print("SENT: Request Previous Moves")
            expectedMovesTimer?.invalidate()
            expectedMovesTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] timer in
                timer.invalidate()
                guard let self = self else {return}
                self.requestPreviousMoves()
            })
            RunLoop.main.add(expectedMovesTimer!, forMode: .common)
        } catch let error {
            print("Error converting struct to data in Network.requestMoves: \(error)")
        }
    }
}
