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
}

enum PacketTypeIn: UInt64 {
    case Connected = 0
    case AlreadyConnected = 1
    case WaitingForPlayers = 2
    case StartGame = 3
    case PlayerMoves = 4
}

class PlayNetwork {
    
    // MARK: Properties
        
    weak var controller: PlayController!
    
//    192.168.0.121 IPad
//    192.168.0.30 Iphone
//    192.168.0.86 Macbook Pro
    
    var connection: NWConnection?
    var hostUDP: NWEndpoint.Host = "192.168.0.86"
    var portUDP: NWEndpoint.Port = 80
    
    var startTime: DispatchTime!
    var endTime: DispatchTime!
    
    let uuid: String
    
    var connected: Bool = false
    
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
    
    // Get Data For Out Type
    func getDataForOutType(type: PacketTypeOut) -> Data {
        var num = type.rawValue
        return Data(bytes: &num, count: 8)
    }
    
    // Send UDP
    func sendUDP(_ content: Data) {
        self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                // Good To Go
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }
    
    // Start Packet Test
    func startPacketTest() {
        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] timer in
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
        
        self.connection?.start(queue: .global())
            
    }
    
    // Send Connection Request
    private func sendConnectionRequest() {
        var data = self.getDataForOutType(type: .Connect)
        data.append(self.uuid.data(using: .utf8)!)
        self.startTime = DispatchTime.now()
        self.sendUDP(data)
        print("Sent Connection Request")
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
                        print("Type: \(type)")
                        switch type {
                        case .WaitingForPlayers:
                            self.handleWaitingForPlayers()
                        case .StartGame:
                            self.handleStartGame(data: data!.subdata(in: 8..<data!.count))
                        case .PlayerMoves:
                            self.handlePlayerMoves(data: data!.subdata(in: 8..<data!.count))
                        default:
                            break
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

