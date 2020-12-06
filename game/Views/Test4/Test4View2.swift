//
//  Test4View2.swift
//  game
//
//  Created by Jackson Tubbs on 12/6/20.
//

import UIKit

class Test4View2: UIView {
    
    // MARK: Properties
    
    var gridWidth: Int = 200
    
    var didSetupView = false
    override var bounds: CGRect {
        didSet {
            if !didSetupView {
//                let display = Test4View()
//                display.translatesAutoresizingMaskIntoConstraints = false
//                addSubview(display)
//                NSLayoutConstraint.activate([
//                    display.topAnchor.constraint(equalTo: topAnchor),
//                    display.leadingAnchor.constraint(equalTo: leadingAnchor),
//                    display.trailingAnchor.constraint(equalTo: trailingAnchor),
//                    display.bottomAnchor.constraint(equalTo: bottomAnchor)
//                ])
//                self.display = display
            }
        }
    }
    
    // MARK: Subviews
    
    private weak var display: Test3View!
    
    // MARK: Init
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
////        let display = Test4View()
////        display.translatesAutoresizingMaskIntoConstraints = false
////        addSubview(display)
////        NSLayoutConstraint.activate([
////            display.topAnchor.constraint(equalTo: topAnchor),
////            display.leadingAnchor.constraint(equalTo: leadingAnchor),
////            display.trailingAnchor.constraint(equalTo: trailingAnchor),
////            display.bottomAnchor.constraint(equalTo: bottomAnchor)
////        ])
////        self.display = display
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    // MARK: Public Functions
    
    // End Game
    func endGame() {
//        display.endGame()
    }
    
    // Reset
    func reset() {
        display.reset()
    }
    
    // Test
    func test() {
        let display = Test4View()
        display.translatesAutoresizingMaskIntoConstraints = false
        addSubview(display)
        NSLayoutConstraint.activate([
            display.topAnchor.constraint(equalTo: topAnchor),
            display.leadingAnchor.constraint(equalTo: leadingAnchor),
            display.trailingAnchor.constraint(equalTo: trailingAnchor),
            display.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
//        self.display = display
    }
    
    // New Grid
    func newGrid() {
        display.newGrid()
    }
}
