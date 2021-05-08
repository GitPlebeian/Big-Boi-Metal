//
//  WaitingForPlayersView.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/7/21.
//

import UIKit

//protocol WaitingForPlayersViewDelegate: class {
//
//}

class WaitingForPlayersView: UIView {

    // MARK: Properties
    
//    weak var delegate: WaitingForPlayersViewDelegate?
    
    // MARK: Views
    
    weak var activityIndicator: UIActivityIndicatorView!
    weak var messageLabel:      UILabel!
    
    // MARK: Init
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        print("Waiting For Players View Delegate DEINIT")
    }
    
    // MARK: Actions
    
    // MARK: Public

    
    // MARK: Private
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        // Activity Indicator
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        self.activityIndicator = activityIndicator
        
        // Message Label
        let messageLabel = UILabel()
        messageLabel.text = "Waiting for players"
        messageLabel.textColor = .white
        messageLabel.font = UIFont(name: Text.robotoBold, size: 18)
        messageLabel.numberOfLines = 1
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        self.messageLabel = messageLabel
    }
}
