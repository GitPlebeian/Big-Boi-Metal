//
//  AlertController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/7/21.
//

import UIKit

class AlertController: UIView {

    // MARK: Properties
    
    weak var controller:            PlayController!
    weak var playMapView:           PlayMapView!
    
    // MARK: Views
    
    weak var waitingForPlayersView: WaitingForPlayersView!
    
    // MARK: Init
    
    init(controller: PlayController,
         playMapView: PlayMapView) {
    
        self.controller = controller
        self.playMapView = playMapView
        
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        print("Alert Controller DEINIT")
    }
    
    // MARK: Actions
    
    // MARK: Public
    
    // Waiting For Players
    func waitingForPlayers() {
        isHidden = false
        waitingForPlayersView.isHidden = false
    }
    
    // Dismiss Alerts
    func dismissAlerts() {
        isHidden = true
        waitingForPlayersView.isHidden = true
    }
    
    // MARK: Private
    
    // MARK: Setup Views
    
    private func setupViews() {
        isHidden = true
        
        translatesAutoresizingMaskIntoConstraints = false
        playMapView.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: playMapView.topAnchor),
            leadingAnchor.constraint(equalTo: playMapView.leadingAnchor),
            trailingAnchor.constraint(equalTo: playMapView.trailingAnchor),
            bottomAnchor.constraint(equalTo: playMapView.bottomAnchor)
        ])
        
        // Waiting For Players View
        let waitingForPlayersView = WaitingForPlayersView()
        waitingForPlayersView.isHidden = true
        waitingForPlayersView.layer.cornerRadius = 16
        waitingForPlayersView.backgroundColor = .background2
        waitingForPlayersView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(waitingForPlayersView)
        NSLayoutConstraint.activate([
            waitingForPlayersView.centerYAnchor.constraint(equalTo: centerYAnchor),
            waitingForPlayersView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        self.waitingForPlayersView = waitingForPlayersView
    }
}
