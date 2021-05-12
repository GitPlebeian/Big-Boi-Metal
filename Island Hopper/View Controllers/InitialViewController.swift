//
//  InitialViewController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/3/21.
//

import UIKit

class InitialViewController: UIViewController {

    // MARK: Properties
    
    // MARK: Views
    
    weak var contentView:     UIView!
    weak var titleLabel:      UILabel!
    weak var mapEditorButton: UIButton!
    weak var playButton:      UIButton!
    weak var pingButton:      UIButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: Actions
    
    // Edit Map Tapped
    @objc private func editMapTapped() {
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let editMapViewController = EditMapViewController()
        window?.rootViewController = editMapViewController
    }
    
    // Play Tapped
    @objc private func playTapped() {
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let selectMapViewController = SelectMapViewController()
        window?.rootViewController = selectMapViewController
    }
    
    // Ping Tapped
    @objc private func pingTapped() {
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let selectMapViewController = PingTestViewController()
        window?.rootViewController = selectMapViewController
    }
    
    // MARK: Public
    
    // MARK: Private
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        view.backgroundColor = .background1
        
        // Content View
        let contentView = UIView()
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .background2
        Layout.centerViewInView(contentView, view)
        self.contentView = contentView
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Island Hopper"
        titleLabel.font = UIFont(name: Text.robotoBlack, size: 32)
        titleLabel.textColor = .white
        Layout.configureView(subView: titleLabel, superView: contentView, top: 16, leading: 16, trailing: -16)
        self.titleLabel = titleLabel
        
        
        // Map Editor Button
        let mapEditorButton = UIButton()
        mapEditorButton.addTarget(self, action: #selector(editMapTapped), for: .touchUpInside)
        mapEditorButton.setTitle("Edit Map", for: .normal)
        mapEditorButton.backgroundColor = .primary
        mapEditorButton.layer.cornerRadius = 8
        mapEditorButton.titleLabel?.font = UIFont(name: Text.robotoBold, size: 14)
        mapEditorButton.titleLabel?.textColor = .white
        mapEditorButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapEditorButton)
        NSLayoutConstraint.activate([
            mapEditorButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            mapEditorButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            mapEditorButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            mapEditorButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.mapEditorButton = mapEditorButton
        
        // Play Button
        let playButton = UIButton()
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.backgroundColor = .primary
        playButton.layer.cornerRadius = 8
        playButton.setTitle("Play", for: .normal)
        playButton.titleLabel?.font = UIFont(name: Text.robotoBold, size: 14)
        playButton.titleLabel?.textColor = .white
        playButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: mapEditorButton.bottomAnchor, constant: 8),
            playButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            playButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.playButton = playButton
        
        // Play Button
        let pingButton = UIButton()
        pingButton.addTarget(self, action: #selector(pingTapped), for: .touchUpInside)
        pingButton.backgroundColor = .primary
        pingButton.layer.cornerRadius = 8
        pingButton.setTitle("Ping", for: .normal)
        pingButton.titleLabel?.font = UIFont(name: Text.robotoBold, size: 14)
        pingButton.titleLabel?.textColor = .white
        pingButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pingButton)
        NSLayoutConstraint.activate([
            pingButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 8),
            pingButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            pingButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            pingButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            pingButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.pingButton = pingButton
    }
}
