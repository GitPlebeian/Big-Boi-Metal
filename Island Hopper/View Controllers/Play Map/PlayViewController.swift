//
//  PlayViewController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/12/21.
//

import UIKit

class PlayViewController: UIViewController {

    // MARK: Properties
    
    var mapURL: URL!
    
    // MARK: Subviews
    
    weak var playView: PlayMapView!
    weak var backButton: UIButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: Overrides
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.top, .bottom, .left, .right]
    }
    
    // MARK: Actions
    
    // Back Button Tapped
    @objc private func backButtonTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let viewController = SelectMapViewController()
        window?.rootViewController = viewController
    }
    
    // MARK: Public
    
    // Add Card
    func addCard(card: Card) {
        
    }
    
    // MARK: Private
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        view.backgroundColor = .background1
        
        let playView = PlayMapView(mapURL: mapURL)
        playView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playView)
        NSLayoutConstraint.activate([
            playView.topAnchor.constraint(equalTo: view.topAnchor),
            playView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.playView = playView
        
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
            backButton.widthAnchor.constraint(equalToConstant: 200),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.backButton = backButton
    }
}
