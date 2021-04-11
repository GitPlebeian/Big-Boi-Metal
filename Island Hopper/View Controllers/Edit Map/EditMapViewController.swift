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
    
    // MARK: Actions

    
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
    }
}
