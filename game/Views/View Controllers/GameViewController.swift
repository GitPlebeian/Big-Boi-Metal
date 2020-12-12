//
//  GameViewController.swift
//  game
//
//  Created by Jackson Tubbs on 12/8/20.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: Properties
    
    // MARK: Views
    
    weak var gameView: GameView!
    
    // MARK: Lifecycle
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: Setup Views
    
    func setupViews() {
        
        view.backgroundColor = .background1
        
        let gameView = GameView()
        gameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameView)
        NSLayoutConstraint.activate([
            gameView.topAnchor.constraint(equalTo: view.topAnchor),
            gameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gameView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.gameView = gameView
    }
}
