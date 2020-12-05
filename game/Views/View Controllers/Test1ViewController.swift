//
//  Test1ViewController.swift
//  game
//
//  Created by Jackson Tubbs on 11/28/20.
//

import UIKit

class Test1ViewController: UIViewController {

    // MARK: Properties
    
    // MARK: Views
    
    weak var test1View: UIView!
    
    // MARK: Style Guide
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: Setup Views
    
    func setupViews() {
        title = "Game Test 1"
        view.backgroundColor = .background1
        
        let newView = UIView()
        newView.layer.borderWidth = 1
        newView.layer.borderColor = UIColor.white.cgColor
        newView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newView)
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newView.heightAnchor.constraint(equalToConstant: 100)
        ])
        let newView2 = UIView()
        newView2.layer.borderWidth = 1
        newView2.layer.borderColor = UIColor.white.cgColor
        newView2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newView2)
        NSLayoutConstraint.activate([
            newView2.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newView2.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newView2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newView2.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Scroll View
        let test1View = Test1View()
        test1View.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(test1View)
        NSLayoutConstraint.activate([
            test1View.topAnchor.constraint(equalTo: newView.bottomAnchor),
            test1View.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            test1View.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            test1View.bottomAnchor.constraint(equalTo: newView2.topAnchor)
        ])
        self.test1View = test1View
        view.bringSubviewToFront(newView)
        view.bringSubviewToFront(newView2)
    }
}
