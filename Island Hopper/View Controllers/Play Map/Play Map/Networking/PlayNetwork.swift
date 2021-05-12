//
//  PlayNetwork.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/6/21.
//

import Foundation
import Network

enum PacketTypeOut: UInt64 {
    case Connect = 0
    case SubmitMoves = 1
    case RequestGameStartData = 2
    case GetPreviousMoves = 3
    case Disconnect = 4
    case Ping = 5
}

enum PacketTypeIn: UInt64 {
    case Connected = 0
    case AlreadyConnected = 1
    case WaitingForPlayers = 2
    case StartGame = 3
    case PlayerMoves = 4
    case RequestPlayerMoves = 5
    case Deleted = 6
    case Ping = 7
}

struct GameUUIDUserUUID: Codable {
    let playerUUID: String
    let gameUUID: String
}

class PlayNetwork {
    
    // MARK: Properties
        
    weak var controller: PlayController!
    
//    192.168.0.121 IPad
//    192.168.0.30 Iphone
//    192.168.0.86 Macbook Pro
    
    var connection: NWConnection?
    var hostUDP: NWEndpoint.Host = "18.225.11.207"
//    var hostUDP: NWEndpoint.Host = "localhost"
    var portUDP: NWEndpoint.Port = 80
    
    var startTime: DispatchTime!
    var endTime: DispatchTime!
    
    let uuid: String
    
    var connected: Bool = false
    
    var serverTickTime: TimeInterval = 0.5
    
    var expectedConnectionTimer: Timer?
    var expectedMovesTimer: Timer?
    var hasReceivedGameStartData: Bool = false
    var expectedRequestGameStartDataTimer: Timer?
    
    // MARK: Delay
    
    var randomDelay: Bool = false
    
    // MARK: Init

    init(controller: PlayController) {
        self.controller = controller
        self.uuid = UUID().uuidString
        connectToUDP(hostUDP,portUDP)
    }
    
    // MARK: Deinit
    
    deinit {
        print("Play Network DEINIT")
    }
    
    // MARK: Public
    
    // Disconnect
    func disconnect() {
        let dataStruct = GameUUIDUserUUID(playerUUID: uuid,
                                          gameUUID: controller.gameUUID)
        do {
            var data = getDataForOutType(type: .Disconnect)
            let structData = try JSONEncoder().encode(dataStruct)
            data.append(structData)
            sendUDP(data)
            print("SENT: Disconnect")
        } catch let error {
            print("Error converting struct to data in Network.disconnect: \(error)")
        }
    }
    
    // Get Data For Out Type
    func getDataForOutType(type: PacketTypeOut) -> Data {
        var num = type.rawValue
        return Data(bytes: &num, count: 8)
    }
    
    // Send UDP
    func sendUDP(_ content: Data) {
        if randomDelay {
            if Float.random(in: 0...1) < 0.3 {
                print("Failing To Send UDP")
                return
            }
//            Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: 1..<4), repeats: false) { [weak self] timer in
//                timer.invalidate()
////                print("Sending UDP")
//            }
//            guard let self = self else {return}
            self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                if (NWError == nil) {
                    
                } else {
                    print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
                }
            })))
        } else {
            self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                if (NWError == nil) {
                    // Good To Go
                } else {
                    print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
                }
            })))
        }
    }
    
    // Start Packet Test
    func startPacketTest() {
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            var data = self.getDataForOutType(type: .Connect)
            data.append(self.uuid.data(using: .utf8)!)
            self.startTime = DispatchTime.now()
            self.sendUDP(data)
            print("Sent Connection Test")
        }
        RunLoop.main.add(timer, forMode: .common)
    }
    
    // MARK: Private
    
    // Get In Type From Data
    private func getPacketInTypeFromData(from data: Data) -> PacketTypeIn? {
        guard data.count >= 8 else {
            return nil
        }
        let num: UInt64 = data.subdata(in: 0..<8).withUnsafeBytes {
            pointer in
            return pointer.load(as: UInt64.self)
        }
        return PacketTypeIn.init(rawValue: num)
    }
    
    // Connect To UDP
    private func connectToUDP(_ hostUDP: NWEndpoint.Host, _ portUDP: NWEndpoint.Port) {
        
        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true
        params.allowFastOpen = true
        
        self.connection = NWConnection(host: hostUDP, port: portUDP, using: params)
        self.connection?.stateUpdateHandler = {[weak self] (newState) in
            guard let self = self else {return}
            switch (newState) {
            case .ready:
                self.sendConnectionRequest()
                self.receiveUDP()
            case .setup:
                print("State: Setup\n")
            case .cancelled:
                print("State: Cancelled\n")
            case .preparing:
                print("State: Preparing\n")
            default:
                print("ERROR! State not defined! \(newState)\n")
            }
        }
//        if randomDelay {
//            self.connection?.start(queue: .main)
//        } else {
//        }
        self.connection?.start(queue: .global())
            
    }
    
    // Send Connection Request
    private func sendConnectionRequest() {
        // Send Data
        var data = self.getDataForOutType(type: .Connect)
        data.append(self.uuid.data(using: .utf8)!)
        self.startTime = DispatchTime.now()
        self.sendUDP(data)
        // Set Expectation Timer
        DispatchQueue.main.async {
            self.expectedConnectionTimer?.invalidate()
            self.expectedConnectionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] timer in
                timer.invalidate()
                guard let self = self else {return}
                self.sendConnectionRequest()
            })
            RunLoop.main.add(self.expectedConnectionTimer!, forMode: .common)
        }
        print("SENT: Connection Request")
    }

    // Receive
    private func receiveUDP() {
        self.connection?.receiveMessage {[weak self] (data, context, isComplete, error) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.endTime = DispatchTime.now()
                //            let nanoTime = self.endTime.uptimeNanoseconds - self.startTime.uptimeNanoseconds
                //            let timeInterval = Double(nanoTime) / 1_000_000 // Technically could overflow for long running tests
                //            print("\(timeInterval)")
                if (isComplete) {
                    if (data != nil) {
                        guard let type = self.getPacketInTypeFromData(from: data!) else {return}
                        if self.randomDelay {
                            if Float.random(in: 0...1) < 0.3 {
                                print("READ Fail: \(type)")
                                return
                            } else {
                                print("READ GOOD: \(type)")
                            }
                        } else {
                            print("Bytes Type: \(type)")
                        }
                        switch type {
                        case .Connected:
                            self.expectedConnectionTimer?.invalidate()
                            // Start Request Game Start Data Timer
                            self.expectedRequestGameStartDataTimer?.invalidate()
                            self.expectedRequestGameStartDataTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] timer in
                                timer.invalidate()
                                guard let self = self else {return}
                                self.requestGameStartData()
                            })
                            RunLoop.main.add(self.expectedRequestGameStartDataTimer!, forMode: .common)
                        case .AlreadyConnected:
                            self.expectedConnectionTimer?.invalidate()
                            // Start Request Game Start Data Timer
                            self.expectedRequestGameStartDataTimer?.invalidate()
                            self.expectedRequestGameStartDataTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] timer in
                                timer.invalidate()
                                guard let self = self else {return}
                                self.requestGameStartData()
                            })
                            RunLoop.main.add(self.expectedRequestGameStartDataTimer!, forMode: .common)
                        case .WaitingForPlayers:
                            self.expectedConnectionTimer?.invalidate()
                            self.handleWaitingForPlayers()
                            // Start Request Game Start Data Timer
                            self.expectedRequestGameStartDataTimer?.invalidate()
                            self.expectedRequestGameStartDataTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { [weak self] timer in
                                timer.invalidate()
                                guard let self = self else {return}
                                self.requestGameStartData()
                            })
                            RunLoop.main.add(self.expectedRequestGameStartDataTimer!, forMode: .common)
                        case .StartGame:
                            self.expectedConnectionTimer?.invalidate()
                            // Cancel Expected Received Game Start Timer
                            self.expectedRequestGameStartDataTimer?.invalidate()
                            if self.hasReceivedGameStartData == true {
                                return
                            }
                            // Handle Start Game
                            self.handleStartGame(data: data!.subdata(in: 8..<data!.count))
                        case .PlayerMoves:
                            if self.hasReceivedGameStartData == false {
                                fatalError("Received Move Data Before Game Start Data")
                            }
                            self.handlePlayerMoves(data: data!.subdata(in: 8..<data!.count))
                        case .RequestPlayerMoves:
                            // You need game start data to send moves
                            if self.hasReceivedGameStartData == false {
                                self.requestGameStartData()
                                return
                            }
                            self.handleRequestPlayerMoves()
                        case .Deleted:
                            self.controller.playMapView.back()
                        case .Ping:
                            print("I was pinged")
                        }
                    } else {
                        print("Data == nil")
                    }
                }
            }
            self.receiveUDP()
        }
    }
}

