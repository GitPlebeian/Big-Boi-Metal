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
    
    weak var debugView: DebugView!
    
    // MARK: Style Guide
    
    var insetSpacing: CGFloat = 16
    
    // MARK: Lifecycle
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: Actions
    
    // MARK: Setup Views
    
    func setupViews() {
        
        view.backgroundColor = .background1
        
        let debugView = DebugView()
        debugView.addSuperView(view)
        self.debugView = debugView
    }
}
