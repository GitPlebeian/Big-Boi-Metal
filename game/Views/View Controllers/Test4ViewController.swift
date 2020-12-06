//
//  Test4ViewController.swift
//  game
//
//  Created by Jackson Tubbs on 12/6/20.
//

import UIKit

class Test4ViewController: UIViewController {

    // MARK: Properties
    
    // MARK: Views
    
    weak var test4View: Test4View2!
    
    // MARK: Style Guide
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        test4View.endGame()
    }
    
    // MARK: Actions
    
    @objc func reset() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        test4View.reset()
    }
    
    @objc func newGrid() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        test4View.newGrid()
    }
    
    @objc func test() {
        test4View.test()
    }
    
    // MARK: Setup Views
    
    func setupViews() {
        title = "4"
        view.backgroundColor = .background1
        
        let test4View = Test4View2()
        test4View.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(test4View)
        NSLayoutConstraint.activate([
            test4View.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            test4View.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            test4View.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            test4View.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.test4View = test4View
        
        let resetBarButtonItem = UIBarButtonItem(title: "Reset", style: .done, target: self, action: #selector(reset))
        
        let newBarButtonItem = UIBarButtonItem(title: "New Grid", style: .done, target: self, action: #selector(newGrid))
        let testBarButtonItem = UIBarButtonItem(title: "Test", style: .done, target: self, action: #selector(test))
        navigationItem.rightBarButtonItems = [testBarButtonItem, resetBarButtonItem, newBarButtonItem]
    }
}
