//
//  Test3ViewController.swift
//  game
//
//  Created by Jackson Tubbs on 11/30/20.
//

import UIKit

class Test3ViewController: UIViewController {

    // MARK: Properties
    
    // MARK: Views
    
    weak var test3View: Test3View!
    
    // MARK: Style Guide
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        test3View.timer.invalidate()
    }
    
    // MARK: Actions
    
    @objc func reset() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        test3View.reset()
    }
    
    @objc func newGrid() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        test3View.newGrid()
    }
    
    @objc func test() {
        test3View.test()
    }
    
    // MARK: Setup Views
    
    func setupViews() {
        title = "3"
        view.backgroundColor = .background1
        
        let test3View = Test3View()
        test3View.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(test3View)
        NSLayoutConstraint.activate([
            test3View.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            test3View.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            test3View.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            test3View.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.test3View = test3View
        
        let resetBarButtonItem = UIBarButtonItem(title: "Reset", style: .done, target: self, action: #selector(reset))
        
        let newBarButtonItem = UIBarButtonItem(title: "New Grid", style: .done, target: self, action: #selector(newGrid))
        let testBarButtonItem = UIBarButtonItem(title: "Test", style: .done, target: self, action: #selector(test))
        navigationItem.rightBarButtonItems = [testBarButtonItem, resetBarButtonItem, newBarButtonItem]
    }
}
