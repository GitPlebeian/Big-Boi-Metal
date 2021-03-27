//
//  Test3ChunkFadeEditor.swift
//  game
//
//  Created by Jackson Tubbs on 3/20/21.
//

import UIKit

class Test3ChunkFadeEditor: UIView {

    // MARK: Properties
    
    weak var gameController: Test3GameController!
    
    // MARK: Views
    
    weak var buttonParentView:     UIView!
    var      configButtons:        [UIButton] = []
    weak var clearSelectionButton: UIButton!
    weak var fadeControlView:      UIView!
    weak var deleteAllButton:      UIButton!
    weak var exportButton:         UIButton!
    
    
    // MARK: Init
    
    init(controller: Test3GameController) {
        self.gameController = controller
        
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    // Export Button Tapped
    @objc private func exportButtonTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        gameController.map.exportMap()
    }
    
    // Delete All Tapped
    @objc private func deleteAllTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        gameController.map.deleteChunks()
    }
    
    // Clear Selection Button Tapped
    @objc private func clearSelectionButtonTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        gameController.map.clearSelectedChunks()
    }
    
    // Config Button Tapped
    @objc private func configButtonTapped(sender:UIButton) {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        let tag = sender.tag

        var dontChangeButtonColor: Int = -1
        switch tag {
        case 0:
            if sender.backgroundColor == .primary {
                sender.backgroundColor = self.tintColor
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.fadeNorthWest)
            } else {
                sender.backgroundColor = .primary
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.fadeNorthWestBig)
            }
        case 1:
            sender.backgroundColor = .primary
            dontChangeButtonColor = tag
            gameController.map.updateSelectedChunksForConfig(.fadeNorth)
        case 2:
            if sender.backgroundColor == .primary {
                sender.backgroundColor = self.tintColor
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.fadeNorthEast)
            } else {
                sender.backgroundColor = .primary
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.fadeNorthEastBig)
            }
        case 3:
            sender.backgroundColor = .primary
            dontChangeButtonColor = tag
            gameController.map.updateSelectedChunksForConfig(.fadeWest)
        case 4:
            if sender.backgroundColor == .primary {
                sender.backgroundColor = self.tintColor
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.ignoreNeighbors)
            } else {
                sender.backgroundColor = .primary
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.normal)
            }
        case 5:
            sender.backgroundColor = .primary
            dontChangeButtonColor = tag
            gameController.map.updateSelectedChunksForConfig(.fadeEast)
        case 6:
            if sender.backgroundColor == .primary {
                sender.backgroundColor = self.tintColor
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.fadeSouthWest)
            } else {
                sender.backgroundColor = .primary
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.fadeSouthWestBig)
            }
        case 7:
            sender.backgroundColor = .primary
            dontChangeButtonColor = tag
            gameController.map.updateSelectedChunksForConfig(.fadeSouth)
        case 8:
            if sender.backgroundColor == .primary {
                sender.backgroundColor = self.tintColor
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.fadeSouthEast)
            } else {
                sender.backgroundColor = .primary
                dontChangeButtonColor = tag
                gameController.map.updateSelectedChunksForConfig(.fadeSouthEastBig)
            }
        default: break
        }
       
        for index in 0..<9 {
            if index != dontChangeButtonColor {
                configButtons[index].backgroundColor = .background2
            }
        }
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        // Button Parent View
        let buttonParentView = UIView()
        buttonParentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonParentView)
        NSLayoutConstraint.activate([
            buttonParentView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            buttonParentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            buttonParentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        self.buttonParentView = buttonParentView
        
        for index in 0..<9 {
            
            // Top Left Config Button
            let configButton = UIButton()
            configButton.tag = index
            configButton.layer.cornerRadius = 8
            configButton.layer.borderColor = UIColor.primary?.cgColor
            configButton.layer.borderWidth = 2
            configButton.backgroundColor = .background2
            configButton.addTarget(self, action: #selector(configButtonTapped(sender:)), for: .touchUpInside)
            configButton.translatesAutoresizingMaskIntoConstraints = false
            buttonParentView.addSubview(configButton)
            if index == 0 {
                configButton.topAnchor.constraint(equalTo: buttonParentView.topAnchor).isActive = true
                configButton.leadingAnchor.constraint(equalTo: buttonParentView.leadingAnchor).isActive = true
            } else if index % 3 == 0 {
                configButton.leadingAnchor.constraint(equalTo: buttonParentView.leadingAnchor).isActive = true
                configButton.topAnchor.constraint(equalTo: configButtons[index - 3].bottomAnchor, constant: 8).isActive = true
            } else {
                configButton.leadingAnchor.constraint(equalTo: configButtons[index - 1].trailingAnchor, constant: 8).isActive = true
                configButton.topAnchor.constraint(equalTo: configButtons[index - 1].topAnchor).isActive = true
            }
            if index == 8 {
                configButton.bottomAnchor.constraint(equalTo: buttonParentView.bottomAnchor).isActive = true
            }
            
            NSLayoutConstraint.activate([
                configButton.widthAnchor.constraint(equalTo: buttonParentView.widthAnchor, multiplier: 0.333333, constant: -5.33333333),
                configButton.heightAnchor.constraint(equalTo: configButton.widthAnchor)
            ])
            configButtons.append(configButton)
        }
        
        // Clear Selection Button Tapped
        let clearSelectionButton = UIButton()
        clearSelectionButton.layer.cornerRadius = 8
        clearSelectionButton.backgroundColor = .primary
        clearSelectionButton.titleLabel?.font = UIFont(name: UIFont.robotoBold, size: 14)
        clearSelectionButton.titleLabel?.textColor = .white
        clearSelectionButton.setTitle("Clear Selection", for: .normal)
        clearSelectionButton.addTarget(self, action: #selector(clearSelectionButtonTapped), for: .touchUpInside)
        clearSelectionButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(clearSelectionButton)
        NSLayoutConstraint.activate([
            clearSelectionButton.topAnchor.constraint(equalTo: buttonParentView.bottomAnchor, constant: 8),
            clearSelectionButton.leadingAnchor.constraint(equalTo: buttonParentView.leadingAnchor),
            clearSelectionButton.trailingAnchor.constraint(equalTo: buttonParentView.trailingAnchor),
            clearSelectionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.clearSelectionButton = clearSelectionButton
        
        // Delete All Button Tapped
        let deleteAllButton = UIButton()
        deleteAllButton.layer.cornerRadius = 8
        deleteAllButton.backgroundColor = .systemRed
        deleteAllButton.titleLabel?.font = UIFont(name: UIFont.robotoBold, size: 14)
        deleteAllButton.titleLabel?.textColor = .white
        deleteAllButton.setTitle("Delete All", for: .normal)
        deleteAllButton.addTarget(self, action: #selector(deleteAllTapped), for: .touchUpInside)
        deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(deleteAllButton)
        NSLayoutConstraint.activate([
            deleteAllButton.topAnchor.constraint(equalTo: clearSelectionButton.bottomAnchor, constant: 8),
            deleteAllButton.leadingAnchor.constraint(equalTo: buttonParentView.leadingAnchor),
            deleteAllButton.trailingAnchor.constraint(equalTo: buttonParentView.trailingAnchor),
            deleteAllButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.deleteAllButton = deleteAllButton
        
        // Export Map Button Tapped
        let exportButton = UIButton()
        exportButton.layer.cornerRadius = 8
        exportButton.backgroundColor = .primary
        exportButton.titleLabel?.font = UIFont(name: UIFont.robotoBold, size: 14)
        exportButton.titleLabel?.textColor = .white
        exportButton.setTitle("Export Map", for: .normal)
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(exportButton)
        NSLayoutConstraint.activate([
            exportButton.topAnchor.constraint(equalTo: deleteAllButton.bottomAnchor, constant: 8),
            exportButton.leadingAnchor.constraint(equalTo: buttonParentView.leadingAnchor),
            exportButton.trailingAnchor.constraint(equalTo: buttonParentView.trailingAnchor),
            exportButton.heightAnchor.constraint(equalToConstant: 44),
            exportButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        self.exportButton = exportButton
        
//        // Let Fade Control View
//        let fadeControlView = UIView()
//        fadeControlView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(fadeControlView)
//        NSLayoutConstraint.activate([
//            fadeControlView.topAnchor.constraint(equalTo: clearSelectionButton.bottomAnchor, constant: 8),
//            fadeControlView.leadingAnchor.constraint(equalTo: clearSelectionButton.leadingAnchor),
//            fadeControlView.trailingAnchor.constraint(equalTo: clearSelectionButton.trailingAnchor),
//            fadeControlView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
//        ])
//        self.fadeControlView = fadeControlView
//
//        // Fade Length Decrement Button
//        let fadeLengthDecrementButton = UIButton()
//        fadeLengthDecrementButton.backgroundColor = .primary
//        fadeLengthDecrementButton.layer.cornerRadius = 8
//        fadeLengthDecrementButton.addTarget(self, action: #selector(fadeLengthDecrement), for: .touchUpInside)
//        fadeLengthDecrementButton.titleLabel?.font = UIFont(name: UIFont.robotoBold, size: 14)
//        fadeLengthDecrementButton.titleLabel?.textColor = .white
//        fadeLengthDecrementButton.setTitle("-", for: .normal)
//        fadeLengthDecrementButton.translatesAutoresizingMaskIntoConstraints = false
//        fadeControlView.addSubview(fadeLengthDecrementButton)
//        NSLayoutConstraint.activate([
//            fadeLengthDecrementButton.topAnchor.constraint(equalTo: fadeControlView.topAnchor),
//            fadeLengthDecrementButton.leadingAnchor.constraint(equalTo: fadeControlView.leadingAnchor),
//            fadeLengthDecrementButton.heightAnchor.constraint(equalToConstant: 44),
//            fadeLengthDecrementButton.widthAnchor.constraint(equalToConstant: 44),
//            fadeLengthDecrementButton.bottomAnchor.constraint(equalTo: fadeControlView.bottomAnchor)
//        ])
//        self.fadeLengthDecrementButton = fadeLengthDecrementButton
//
//        // Fade Length Value Label
//        let fadeLengthValueLabel = UILabel()
//        fadeLengthValueLabel.font = UIFont(name: UIFont.robotoBold, size: 14)
//        fadeLengthValueLabel.
    }
}
