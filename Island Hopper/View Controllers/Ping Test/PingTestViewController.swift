//
//  PingTestViewController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/11/21.
//

import UIKit
import Network

class PingTestViewController: UIViewController {

    // MARK: Properties
    
    
    var connection: NWConnection?
    var hostUDP: NWEndpoint.Host = "18.225.11.207"
//    var hostUDP: NWEndpoint.Host = "localhost"
    var portUDP: NWEndpoint.Port = 80
    
    var startTime: DispatchTime!
    var endTime: DispatchTime!
    
    private var previousPings: [Double] = []
    
    // MARK: Subviews
    
    weak var backButton: UIButton!
    weak var pingLabel: UILabel!
    weak var highestPingLabel: UILabel!
    weak var lowestPingLabel: UILabel!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        connectToUDP(hostUDP,portUDP)
    }
    
    // MARK: Deinit
    
    deinit {
        print("Ping View Controller DEINIT")
    }
    
    // MARK: Overrides
    
    // MARK: Actions
    
    // Back Button Tapped
    @objc private func backButtonTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let viewController = InitialViewController()
        window?.rootViewController = viewController
    }
    
    // MARK: Public
    
    
    // MARK: Private
    
    // Update Ping Label
    private func updatePingLabel(time: Double) {
        if previousPings.count >= 50 {
            previousPings.remove(at: 0)
        }
        previousPings.append(time)
        var totalTime: Double = 0
        var lowestPing: Double = .infinity
        var highestPing: Double = -.infinity
        for time in previousPings {
            totalTime += time
            if time < lowestPing {
                lowestPing = time
            }
            if time > highestPing {
                highestPing = time
            }
        }
        pingLabel.text = "Ave \((totalTime / Double(previousPings.count) * 100).rounded(.down) / 100)"
        lowestPingLabel.text = "Low \((lowestPing * 100).rounded(.down) / 100)"
        highestPingLabel.text = "High \((highestPing * 100).rounded(.down) / 100)"
    }
    
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
                self.sendPing()
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
        self.connection?.start(queue: .main)
            
    }
    
    // Send Ping
    func sendPing() {
        self.startTime = DispatchTime.now()
        var num = PacketTypeOut.Ping.rawValue
        let data = Data(bytes: &num, count: 8)
        self.connection?.send(content: data, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                // Good To Go
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }
    
    // Receive
    private func receiveUDP() {
        self.connection?.receiveMessage {[weak self] (data, context, isComplete, error) in
            guard let self = self else {return}
            self.endTime = DispatchTime.now()
            DispatchQueue.main.async {
                let nanoTime = self.endTime.uptimeNanoseconds - self.startTime.uptimeNanoseconds
                let timeInterval = Double(nanoTime) / 1_000_000 // Technically could overflow for long running tests
                if (isComplete) {
                    if (data != nil) {
                        guard let type = self.getPacketInTypeFromData(from: data!) else {
                            print("Incorrect Ping Receive")
                            return
                        }
                        if type == .Ping {
                            self.sendPing()
                        }
                    } else {
                        print("Data == nil")
                    }
                }
                self.updatePingLabel(time: timeInterval)
            }
            self.receiveUDP()
        }
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        view.backgroundColor = .background1
        
        // Back Button
        let backButton = UIButton()
        backButton.backgroundColor = .primary
        backButton.layer.cornerRadius = 8
        backButton.titleLabel?.font = UIFont(name: Text.robotoBold, size: 14)
        backButton.titleLabel?.textColor = .white
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 160),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.backButton = backButton
        
        // Ping Label
        let pingLabel = UILabel()
        pingLabel.font = UIFont(name: Text.robotoBold, size: 36)
        pingLabel.textColor = .white
        pingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pingLabel)
        NSLayoutConstraint.activate([
            pingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        self.pingLabel = pingLabel
        
        // Highest Ping Label
        let highestPingLabel = UILabel()
        highestPingLabel.font = UIFont(name: Text.robotoBold, size: 36)
        highestPingLabel.textColor = .white
        highestPingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(highestPingLabel)
        NSLayoutConstraint.activate([
            highestPingLabel.bottomAnchor.constraint(equalTo: pingLabel.topAnchor, constant: -16),
            highestPingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        self.highestPingLabel = highestPingLabel
        
        // Lowest Ping Label
        let lowestPingLabel = UILabel()
        lowestPingLabel.font = UIFont(name: Text.robotoBold, size: 36)
        lowestPingLabel.textColor = .white
        lowestPingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lowestPingLabel)
        NSLayoutConstraint.activate([
            lowestPingLabel.topAnchor.constraint(equalTo: pingLabel.bottomAnchor, constant: 16),
            lowestPingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        self.lowestPingLabel = lowestPingLabel
    }
}
