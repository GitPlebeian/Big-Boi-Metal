//
//  GameViewDebugTest.swift
//  game
//
//  Created by Jackson Tubbs on 3/2/21.
//

import UIKit

class GameViewDebugTest {
    
    // MARK: Properties
    
    var animationState:        AnimationState = .closed
    var testing:               Bool           = false
    
    // MARK: Views
    
    // Parent Views
    var debugView:             DebugView
    // Debug View
    weak var scrollView:       UIScrollView!
    weak var testToggleButton: UIButton!
    
    init(debugView: DebugView) {
        self.debugView = debugView
        setup()
    }
    
    // MARK: Actions
    
    // Toggle Test
    @objc private func toggleTest() {
        debugView.selectionFeedback.selectionChanged()
        if testing {
            testing = !testing
            testToggleButton.setTitle("Start Test", for: .normal)
            endTest()
        } else {
            testing = !testing
            testToggleButton.setTitle("End Test", for: .normal)
            debugView.close {
                self.startTest()
            }
        }
    }
    
    // MARK: Public
    
    // Start Test
    func startTest() {
        debugView.superview!.bringSubviewToFront(debugView)
    }
    
    // End Test
    func endTest() {
        hideContentView()
    }
    
    // Show Content View
    func showContentView() {
        animationState = .animating
        scrollView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.scrollView.layer.opacity = 1
        } completion: { (_) in
            self.animationState = .open
        }
    }
    
    // MARK: Helpers
    
    // Hide Content View
    private func hideContentView() {
        animationState = .animating
        UIView.animate(withDuration: 0.2) {
            self.scrollView.layer.opacity = 0
        } completion: { (_) in
            self.scrollView.isHidden = true
            self.animationState = .closed
            self.debugView.showDebugList()
        }
    }
    
    // MARK: Setup
    
    private func setup() {
        
        // Content View
        let scrollView = UIScrollView()
        scrollView.layer.opacity = 0
        scrollView.isHidden = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .background1
        scrollView.layer.cornerRadius = 16
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        debugView.contentView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: debugView.toggleButton.bottomAnchor, constant: debugView.contentSpacing),
            scrollView.leadingAnchor.constraint(equalTo: debugView.leadingAnchor, constant: debugView.contentSpacing),
            scrollView.trailingAnchor.constraint(equalTo: debugView.trailingAnchor, constant: -debugView.contentSpacing),
            scrollView.bottomAnchor.constraint(equalTo: debugView.bottomAnchor, constant: -debugView.contentSpacing)
        ])
        self.scrollView = scrollView
        
        // End Test Button
        let testToggleButton = UIButton()
        testToggleButton.addTarget(self, action: #selector(toggleTest), for: .touchUpInside)
        testToggleButton.layer.cornerRadius = debugView.elementCornerRadius
        testToggleButton.titleLabel?.font = UIFont(name: UIFont.robotoBlack, size: 16)
        testToggleButton.backgroundColor = debugView.buttonBackgroundColor
        testToggleButton.setTitle("Start Test", for: .normal)
        testToggleButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(testToggleButton)
        NSLayoutConstraint.activate([
            testToggleButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: debugView.contentSpacing),
            testToggleButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: debugView.contentSpacing),
            testToggleButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -debugView.contentSpacing),
            testToggleButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            testToggleButton.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -debugView.contentSpacing * 2),
            testToggleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.testToggleButton = testToggleButton
    }
}
