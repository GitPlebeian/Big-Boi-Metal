//
//  EditMapViewController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/3/21.
//

import UIKit

class EditMapViewController: UIViewController {

    // MARK: Properties
    
    // MARK: Views
    
    weak var mapEditorView:     MapEditorView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: Deinit
    
    deinit {
        print("Edit Map View Controller Deinit")
    }
    
    // MARK: Actions
    
    // Back Button Tapped
    @objc private func backButtonTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let initialViewController = InitialViewController()
        window?.rootViewController = initialViewController
    }
    
    
    // MARK: Public
    
    // MARK: Private
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        view.backgroundColor = .background1

        // Map Editor View
        let mapEditorView = MapEditorView()
        mapEditorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapEditorView)
        NSLayoutConstraint.activate([
            mapEditorView.topAnchor.constraint(equalTo: view.topAnchor),
            mapEditorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapEditorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapEditorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.mapEditorView = mapEditorView
        
        // Back Button
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
            backButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 200),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}