//
//  Test2ViewController.swift
//  game
//
//  Created by Jackson Tubbs on 11/28/20.
//

import UIKit

class Test2ViewController: UIViewController {

    // MARK: Properties
    
    // MARK: Views
    
    weak var test2View: UIView!
    
    // MARK: Style Guide
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: Setup Views
    
    func setupViews() {
        title = "2"
        view.backgroundColor = .background1
        
        let test2View = Test2View()
        test2View.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(test2View)
        NSLayoutConstraint.activate([
            test2View.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            test2View.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            test2View.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            test2View.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.test2View = test2View
    }
}
