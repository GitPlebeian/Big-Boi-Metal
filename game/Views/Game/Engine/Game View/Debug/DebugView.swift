//
//  DebugView.swift
//  game
//
//  Created by Jackson Tubbs on 12/17/20.
//

import UIKit

class DebugView: UIView {
    
    // MARK: Properties
    
    var      animationState:                   AnimationState               = .closed
    var      debugListAnimationState:          AnimationState               = .open
    var      selectionFeedback:                UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    // Tests
    var      test1:                            Test1!
    
    // MARK: Style Guide
    
    var      topPadding:                       CGFloat                      = 0
    var      bottomPadding:                    CGFloat                      = 0
    var      toggleButtonSize:                 CGFloat                      = 44
    var      insetSpacing:                     CGFloat                      = 16
    var      desiredWidth:                     CGFloat                      = 300
    var      contentSpacing:                   CGFloat                      = 8
    
    // Debug Elements
    var      buttonBackgroundColor:            UIColor!                     = .primary
    var      elementCornerRadius:              CGFloat                      = 8
    
    // MARK: Views
    
    weak var toggleButton:                     UIButton!
    weak var contentView:                      UIView!
    weak var titleLabel:                       UILabel!
    weak var scrollView:                       UIScrollView!
    weak var startTestButton1:                 UIButton!
    
    // MARK: Constraints
    
    var      widthConstraint:                  NSLayoutConstraint!
    var      heightConstraint:                 NSLayoutConstraint!
    
    // Toggle Button
    var      toggleButtonVerticalConstraint:   NSLayoutConstraint!
    var      toggleButtonHorizontalConstraint: NSLayoutConstraint!
    var      toggleButtonHeightConstraint:     NSLayoutConstraint!
    var      toggleButtonWidthConstraint:      NSLayoutConstraint!
    
    // MARK: Actions
    
    // Toggle Button Tapped
    @objc private func toggleButtonTapped() {
        selectionFeedback.selectionChanged()
        
        // Opens Debug View
        if animationState == .open {
            close(nil)
        } else if animationState == .closed {
            open()
        }
    }
    
    // Start Test 1
    @objc private func startTestButton1Tapped() {
        selectionFeedback.selectionChanged()
        if debugListAnimationState == .open {
            hideDebugList {
                self.test1.showContentView()
            }
        }
    }
    
    // MARK: API
    
    // Add Superver
    func addSuperView(view: UIView) {
        let window = UIApplication.shared.windows[0]
        topPadding = window.safeAreaInsets.top
        bottomPadding = window.safeAreaInsets.bottom
        setupViews(view: view)
        test1 = Test1(gameView: view as! GameView, debugView: self)
    }
    
    // Update
    func update(_ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            if self.test1.testing {
                self.test1.update()
            }
            completion()
        }
    }
    
    // MARK: Helpers
    
    // Close
    func close(_ completion: (() -> Void)?) {
        self.animationState = .animating
        let animation = UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1) {
            self.contentView.layer.opacity = 0
        }
        animation.addCompletion { (_) in
            // Main
            self.widthConstraint.isActive = false
            self.widthConstraint = self.widthAnchor.constraint(equalToConstant: self.toggleButtonSize)
            self.widthConstraint.isActive = true
            self.heightConstraint.isActive = false
            self.heightConstraint = self.heightAnchor.constraint(equalToConstant: self.toggleButtonSize)
            self.heightConstraint.isActive = true
            
            // Toggle Button
            self.toggleButtonVerticalConstraint.isActive = false
            self.toggleButtonVerticalConstraint = self.toggleButton.topAnchor.constraint(equalTo: self.topAnchor)
            self.toggleButtonVerticalConstraint.isActive = true
            self.toggleButtonHorizontalConstraint.isActive = false
            self.toggleButtonHorizontalConstraint = self.toggleButton.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            self.toggleButtonHorizontalConstraint.isActive = true
            self.toggleButtonHeightConstraint.isActive = false
            self.toggleButtonHeightConstraint = self.toggleButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            self.toggleButtonHeightConstraint.isActive = true
            self.toggleButtonWidthConstraint.isActive = false
            self.toggleButtonWidthConstraint = self.toggleButton.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            self.toggleButtonWidthConstraint.isActive = true
            
            let animation2 = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
                self.superview!.layoutIfNeeded()
                self.toggleButton.backgroundColor = .background2
            }
            animation2.addCompletion { (_) in
                self.animationState = .closed
                completion?()
            }
            animation2.startAnimation()
        }
        animation.startAnimation()
    }
    
    // Open
    private func open() {
        // Main
        widthConstraint.isActive = false
        widthConstraint = widthAnchor.constraint(equalToConstant: desiredWidth)
        widthConstraint.isActive = true
        heightConstraint.isActive = false
        heightConstraint = bottomAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.bottomAnchor, constant: -insetSpacing)
        heightConstraint.isActive = true
        
        // Toggle Button
        toggleButtonHeightConstraint.isActive = false
        toggleButtonHeightConstraint = toggleButton.heightAnchor.constraint(equalToConstant: toggleButtonSize)
        toggleButtonHeightConstraint.isActive = true
        toggleButtonWidthConstraint.isActive = false
        toggleButtonWidthConstraint = toggleButton.widthAnchor.constraint(equalToConstant: toggleButtonSize)
        toggleButtonWidthConstraint.isActive = true
        toggleButtonVerticalConstraint.isActive = false
        toggleButtonVerticalConstraint = toggleButton.topAnchor.constraint(equalTo: topAnchor, constant: contentSpacing)
        toggleButtonVerticalConstraint.isActive = true
        toggleButtonHorizontalConstraint.isActive = false
        toggleButtonHorizontalConstraint = toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentSpacing)
        toggleButtonHorizontalConstraint.isActive = true
        
        animationState = .animating
        let animation = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1) {
            self.superview!.layoutIfNeeded()
            self.toggleButton.backgroundColor = .background1
            
        }
        animation.addCompletion { (_) in
            let animation2 = UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1) {
                self.contentView.layer.opacity = 1
            }
            animation2.addCompletion { (_) in
                self.animationState = .open
            }
            animation2.startAnimation()
        }
        animation.startAnimation()
    }
    
    // Hide Debug List
    private func hideDebugList(_ completion: (() -> Void)?) {
        if debugListAnimationState == .closed || debugListAnimationState == .animating {
            return
        }
        debugListAnimationState = .animating
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.layer.opacity = 0
        }, completion: { _ in
            self.scrollView.isHidden = true
            self.debugListAnimationState = .closed
            completion?()
        })
    }
    
    // Show Debug List
    func showDebugList() {
        if debugListAnimationState == .open || debugListAnimationState == .animating {
            return
        }
        debugListAnimationState = .animating
        self.scrollView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.scrollView.layer.opacity = 1
        } completion: { (_) in
            self.debugListAnimationState = .open
        }

    }
    
    // MARK: Setup Views
    
    private func setupViews(view: UIView) {
        backgroundColor = .background2
        layer.cornerRadius = 16
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        widthConstraint = widthAnchor.constraint(equalToConstant: toggleButtonSize)
        heightConstraint = heightAnchor.constraint(equalToConstant: toggleButtonSize)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: insetSpacing),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -insetSpacing),
            widthConstraint,
            heightConstraint
        ])
        
        // Content View
        let contentView = UIView()
        contentView.layer.opacity = 0
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.contentView = contentView
        
        // Toggle Button
        let toggleButton = UIButton()
        toggleButton.layer.cornerRadius = 16
        toggleButton.backgroundColor = .background2
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toggleButton)
        toggleButtonVerticalConstraint = toggleButton.topAnchor.constraint(equalTo: topAnchor)
        toggleButtonHorizontalConstraint = toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        toggleButtonHeightConstraint = toggleButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        toggleButtonWidthConstraint = toggleButton.leadingAnchor.constraint(equalTo: leadingAnchor)
        NSLayoutConstraint.activate([
            toggleButtonVerticalConstraint,
            toggleButtonHorizontalConstraint,
            toggleButtonHeightConstraint,
            toggleButtonWidthConstraint
        ])
        self.toggleButton = toggleButton
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: UIFont.robotoBlack, size: 18)
        titleLabel.text = "Debug"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: toggleButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: toggleButton.trailingAnchor, constant: -contentSpacing)
        ])
        self.titleLabel = titleLabel
        
        // Scroll View
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .background1
        scrollView.layer.cornerRadius = 16
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: contentSpacing),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentSpacing),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -contentSpacing),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -contentSpacing)
        ])
        self.scrollView = scrollView
        
        // Start Test Button 1
        let startTestButton1 = UIButton()
        startTestButton1.addTarget(self, action: #selector(startTestButton1Tapped), for: .touchUpInside)
        startTestButton1.layer.cornerRadius = elementCornerRadius
        startTestButton1.titleLabel?.font = UIFont(name: UIFont.robotoBlack, size: 16)
        startTestButton1.backgroundColor = buttonBackgroundColor
        startTestButton1.setTitle("Flight Test", for: .normal)
        startTestButton1.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(startTestButton1)
        NSLayoutConstraint.activate([
            startTestButton1.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: contentSpacing),
            startTestButton1.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: contentSpacing),
            startTestButton1.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -contentSpacing),
            startTestButton1.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            startTestButton1.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -contentSpacing * 2),
            startTestButton1.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.startTestButton1 = startTestButton1
    }
}
