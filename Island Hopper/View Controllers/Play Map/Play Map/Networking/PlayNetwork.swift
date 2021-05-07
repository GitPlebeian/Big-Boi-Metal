//
//  PlayNetwork.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/6/21.
//

import Foundation
import Network

struct Person: Codable {
    var name: String
    var age: Int
}

enum PacketTypeOut: UInt64 {
    case Connect = 0
}

enum PacketTypeIn: UInt64 {
    case Connected = 0
}

class PlayNetwork {
    
    // MARK: Properties
        
    weak var controller: PlayController!
    
    
    var connection: NWConnection?
    var hostUDP: NWEndpoint.Host = "192.168.0.83"
    var portUDP: NWEndpoint.Port = 80
    
    var startTime: DispatchTime!
    var endTime: DispatchTime!
    
    // MARK: Init

    init(controller: PlayController) {
        self.controller = controller
        connectToUDP(hostUDP,portUDP)
    }
    
    // MARK: Deinit
    
    deinit {
        print("Play Network DEINIT")
    }
    
    func connectToUDP(_ hostUDP: NWEndpoint.Host, _ portUDP: NWEndpoint.Port) {
        

        
        do {

            self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)

            self.connection?.stateUpdateHandler = {[weak self] (newState) in
                guard let self = self else {return}
                print("This is stateUpdateHandler:")
                switch (newState) {
                    case .ready:
                        print("State: Ready\n")
                        var packetTypeOut: UInt64 = PacketTypeOut.Connect.rawValue
                        var connectionRequestData = Data(bytes: &packetTypeOut, count: 8)
                        
                        let uuid = UUID().uuidString
                        let uuidData = try! JSONEncoder().encode(uuid)
                        connectionRequestData.append(uuidData)
                        self.startTime = DispatchTime.now()
                        self.sendUDP(connectionRequestData)
                        self.receiveUDP()
                    case .setup:
                        print("State: Setup\n")
                    case .cancelled:
                        print("State: Cancelled\n")
                    case .preparing:
                        print("State: Preparing\n")
                    default:
                        print("ERROR! State not defined!\n")
                }
            }

            self.connection?.start(queue: .global())
            
            
            // and decode it back
//            let decodedSentences = try JSONDecoder().decode([Sentence].self, from: jsonData)
//            print(decodedSentences)
        } catch { print(error) }
    }

    func sendUDP(_ content: Data) {
        self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    func sendUDP(_ content: String) {
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
        self.connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            
            if (NWError == nil) {
                print("Data was sent to UDP")
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }

    func receiveUDP() {
        self.connection?.receiveMessage {[weak self] (data, context, isComplete, error) in
            guard let self = self else {return}
            self.endTime = DispatchTime.now()
            let nanoTime = self.endTime.uptimeNanoseconds - self.startTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000 // Technically could overflow for long running tests
            print("Time: \(timeInterval)")
            if (isComplete) {
                print("Receive is complete")
                if (data != nil) {
//                    let backToString = String(decoding: data!, as: UTF8.self)
//                    print("Received message: \(backToString)")
                    do {
                        let string = String(decoding: data!, as: UTF8.self)
//                        let person = tr`y JSONDecoder().decode(String.self, from: data!)
                        print(string)
                    } catch let e {
                        print("Big EE: \(e)")
                    }
                } else {
                    print("Data == nil")
                }
            }
        }
    }
}

