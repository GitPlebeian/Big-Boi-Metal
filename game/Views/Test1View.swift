//
//  Test1View.swift
//  game
//
//  Created by Jackson Tubbs on 11/28/20.
//

import UIKit

class Test1View: UIView {
    
    // MARK: Properties
    
    var didSetupView = false
    override var bounds: CGRect {
        didSet {
            if !didSetupView {
                setupViews()
                didSetupView = true
            }
        }
    }
    let defaultGridWidth: Int = 60
    
    // MARK: Views
    
    var cells: [UIView] = []
    
    // MARK: Style Guide
    
    // MARK: Setup Views
    
    func setupViews() {
        print("Screen Width: \(bounds.width)")
        print("Screen Height: \(bounds.height)")
        let cellSize: CGFloat = bounds.width / CGFloat(defaultGridWidth)
        print("Cell Size: \(cellSize)")
        print("Height / Cell Size: \(bounds.height / cellSize)")
        
        print("Cells Needed To Fill Space: \((bounds.height / cellSize).rounded(.up))")
        
        
        // Get Starting Point For Starting Y
        var yCellsRequired = Int((bounds.height / cellSize).rounded(.up))
        if yCellsRequired % 2 == 1 {
            yCellsRequired += 1
        }
        let yStartingPoint1 = CGFloat(yCellsRequired) * cellSize
        let yStartingPoint2 = bounds.height - yStartingPoint1
        let yStartingPoint =  yStartingPoint2 / 2
        print(yStartingPoint1)
        print(yStartingPoint2)
        print("Starting Point: \(yStartingPoint)")
        
        for y in 0..<yCellsRequired {
            for x in 0..<defaultGridWidth {
                
                let view = UIView()
                let randomNum = Int.random(in: 0..<7)
                switch randomNum {
                case 0: view.backgroundColor = .systemBlue
                case 1: view.backgroundColor = .systemPink
                case 2: view.backgroundColor = .systemTeal
                case 3: view.backgroundColor = .systemGreen
                case 4: view.backgroundColor = .systemYellow
                case 5: view.backgroundColor = .systemOrange
                case 6: view.backgroundColor = .systemIndigo
                default:
                    view.backgroundColor = .background1
                }
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                let topConstraintConstant: CGFloat = yStartingPoint + cellSize * CGFloat(y)
                let leadingConstraintConstant: CGFloat = cellSize * CGFloat(x)
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: topAnchor, constant: topConstraintConstant),
                    view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingConstraintConstant),
                    view.widthAnchor.constraint(equalToConstant: cellSize),
                    view.heightAnchor.constraint(equalToConstant: cellSize)
                ])
            }
        }
        
        let centerDot = UIView()
        centerDot.backgroundColor = .red
        centerDot.layer.cornerRadius = 2
        centerDot.translatesAutoresizingMaskIntoConstraints = false
        addSubview(centerDot)
        NSLayoutConstraint.activate([
            centerDot.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerDot.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerDot.heightAnchor.constraint(equalToConstant: 4),
            centerDot.widthAnchor.constraint(equalToConstant: 4)
        ])
    }
}
