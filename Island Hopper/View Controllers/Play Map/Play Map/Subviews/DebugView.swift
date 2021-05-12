//
//  DebugView.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/11/21.
//

import UIKit

class DebugView: UIView {

    // MARK: Properties
    
    weak var controller:  PlayController!
    
    // MARK: Subviews
    
    weak var stepLabel: UILabel!
    weak var waitingServerMovesAI: UIActivityIndicatorView!
    
    // MARK: Init
    
    init(controller: PlayController,
         playView:   PlayMapView) {
        self.controller = controller
        super.init(frame: .zero)
        setupViews(playView: playView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        print("Debug View DEINIT")
    }
    
    // MARK: Public
    
    // Start Waiting For Server Moves
    func startWaitingForServerMoves() {
        waitingServerMovesAI.startAnimating()
    }
    
    // MARK: Private
    
    func stopWaitingForServerMoves() {
        waitingServerMovesAI.stopAnimating()
    }
    
    // MARK: Setup Views
    
    private func setupViews(playView: PlayMapView) {
        
        // Self
        backgroundColor = .background2
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 4
        playView.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: playView.safeAreaLayoutGuide.topAnchor, constant: 8),
            trailingAnchor.constraint(equalTo: playView.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
        
        // Step Label
        let stepLabel = UILabel()
        stepLabel.font = UIFont(name: Text.robotoBold, size: 12)
        stepLabel.textColor = .white
        stepLabel.text = "Step: \(0)"
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stepLabel)
        NSLayoutConstraint.activate([
            stepLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stepLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stepLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        self.stepLabel = stepLabel
        
        // Waiting For Server Moves Activity Indicaotr
        let waitingServerMovesAI = UIActivityIndicatorView(style: .medium)
        waitingServerMovesAI.hidesWhenStopped = true
        waitingServerMovesAI.color = .white
        waitingServerMovesAI.translatesAutoresizingMaskIntoConstraints = false
        addSubview(waitingServerMovesAI)
        NSLayoutConstraint.activate([
            waitingServerMovesAI.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 4),
            waitingServerMovesAI.leadingAnchor.constraint(equalTo: stepLabel.leadingAnchor),
            waitingServerMovesAI.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        self.waitingServerMovesAI = waitingServerMovesAI
    }
}
