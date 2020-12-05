//
//  InitialViewController.swift
//  game
//
//  Created by Jackson Tubbs on 11/14/20.
//

import UIKit

class InitialViewController: UIViewController {

    // MARK: Properties
    
    // MARK: Views
    
    weak var titleLabel: UILabel!
    weak var testGameButton1: UIButton!
    weak var testGameButton2: UIButton!
    weak var testGameButton3: UIButton!
    
    // MARK: Style Guide
    
    // MARK: Lifecycle
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: Actions
    
    // Test Game Button 1 Tapped
    @objc func testGameButton1Tapped() {
        let viewController = Test1ViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Test Game Button 2 Tapped
    @objc func testGameButton2Tapped() {
        let viewController = Test2ViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // Test Game Button 3 Tapped
    @objc func testGameButton3Tapped() {
        let viewController = Test3ViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        title = "Game"
        view.backgroundColor = .background1
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.font = .title
        titleLabel.text = "GAME"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        self.titleLabel = titleLabel
        
        // Test Game Button 1
        let testGameButton1 = UIButton()
        testGameButton1.addTarget(self, action: #selector(testGameButton1Tapped), for: .touchUpInside)
        testGameButton1.backgroundColor = .background2
        testGameButton1.layer.cornerRadius = 12
        testGameButton1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testGameButton1)
        NSLayoutConstraint.activate([
            testGameButton1.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            testGameButton1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testGameButton1.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            testGameButton1.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.testGameButton1 = testGameButton1
        
        // Test Game Button 2
        let testGameButton2 = UIButton()
        testGameButton2.addTarget(self, action: #selector(testGameButton2Tapped), for: .touchUpInside)
        testGameButton2.backgroundColor = .background2
        testGameButton2.layer.cornerRadius = 12
        testGameButton2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testGameButton2)
        NSLayoutConstraint.activate([
            testGameButton2.topAnchor.constraint(equalTo: testGameButton1.bottomAnchor, constant: 8),
            testGameButton2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testGameButton2.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            testGameButton2.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.testGameButton2 = testGameButton2
        
        // Test Game Button 3
        let testGameButton3 = UIButton()
        testGameButton3.addTarget(self, action: #selector(testGameButton3Tapped), for: .touchUpInside)
        testGameButton3.backgroundColor = .background2
        testGameButton3.layer.cornerRadius = 12
        testGameButton3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(testGameButton3)
        NSLayoutConstraint.activate([
            testGameButton3.topAnchor.constraint(equalTo: testGameButton2.bottomAnchor, constant: 8),
            testGameButton3.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testGameButton3.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            testGameButton3.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.testGameButton3 = testGameButton3
    }
}
