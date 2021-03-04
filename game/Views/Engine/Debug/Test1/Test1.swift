//
//  Test1.swift
//  game
//
//  Created by Jackson Tubbs on 12/17/20.
//

import UIKit

// Flight Test
class Test1: GameViewDebugTest {
    
    
    // Controls
    var panControlRadius:      CGFloat        = 120
    var leftControlCenter:     CGPoint        = .zero
    var leftControl:           CGPoint        = .zero
    var rightControlCenter:    CGPoint        = .zero
    var rightControl:          CGPoint        = .zero
    
    // MARK: Views
    
    weak var gameView:         GameView1!
    
    // Controls
    weak var leftView:         UIView!
    weak var leftControlView:  UIView!
    weak var rightView:        UIView!
    weak var rightControlView: UIView!
    
    // MARK: Gestures
    
    var leftPan:               UIPanGestureRecognizer!
    var rightPan:              UIPanGestureRecognizer!

    // MARK: Actions
    
    // Left Pan
    @objc private func leftPanMoved() {
        let location = leftPan.location(in: nil)
        if leftPan.state == .began {
            debugView.selectionFeedback.selectionChanged()
            leftControlCenter = location
            
            // Left Control View
            let leftControlView = UIView()
            leftControlView.layer.cornerRadius = panControlRadius
            leftControlView.layer.borderWidth = 1
            leftControlView.layer.borderColor = UIColor.white.cgColor
            leftControlView.translatesAutoresizingMaskIntoConstraints = false
            leftView.addSubview(leftControlView)
            leftControlView.frame = CGRect(x: location.x - panControlRadius,
                                           y: location.y - panControlRadius,
                                           width: panControlRadius * 2,
                                           height: panControlRadius * 2)
            self.leftControlView = leftControlView
        }
        
        if leftPan.state == .ended {
            leftControlView.removeFromSuperview()
            leftControl = .zero
            return
        }
        
        var xDifference = (location.x - leftControlCenter.x) / panControlRadius
        var yDifference = (location.y - leftControlCenter.y) / panControlRadius
        if xDifference > 1 {
            xDifference = 1
        }
        if xDifference < -1 {
            xDifference = -1
        }
        if yDifference > 1 {
            yDifference = 1
        }
        if yDifference < -1 {
            yDifference = -1
        }
        leftControl.x = xDifference
        leftControl.y = yDifference
    }
    
    // Right Pan
    @objc private func rightPanMoved() {
        let location = rightPan.location(in: rightView)
        if rightPan.state == .began {
            debugView.selectionFeedback.selectionChanged()
            rightControlCenter = location
            
            // Left Control View
            let rightControlView = UIView()
            rightControlView.layer.cornerRadius = panControlRadius
            rightControlView.layer.borderWidth = 1
            rightControlView.layer.borderColor = UIColor.white.cgColor
            rightControlView.translatesAutoresizingMaskIntoConstraints = false
            rightView.addSubview(rightControlView)
            rightControlView.frame = CGRect(x: location.x - panControlRadius,
                                           y: location.y - panControlRadius,
                                           width: panControlRadius * 2,
                                           height: panControlRadius * 2)
            self.rightControlView = rightControlView
        }
        
        if rightPan.state == .ended {
            rightControlView.removeFromSuperview()
            rightControl = .zero
            return
        }
        
        var xDifference = (location.x - rightControlCenter.x) / panControlRadius
        var yDifference = (location.y - rightControlCenter.y) / panControlRadius
        if xDifference > 1 {
            xDifference = 1
        }
        if xDifference < -1 {
            xDifference = -1
        }
        if yDifference > 1 {
            yDifference = 1
        }
        if yDifference < -1 {
            yDifference = -1
        }
        rightControl.x = xDifference
        rightControl.y = yDifference
    }
    
    // MARK: Helpers
    
    // Update Player Ship
    private func updatePlayerShip(_ playerShip: inout PlayerShip) {
        
    }
    
    // Start Test
    override func startTest() {
        
        let gameView = GameView1(frame: UIScreen.main.bounds)
        gameView.delegate = self
        let gameViewSuperView = debugView.superview!
        gameViewSuperView.addSubview(gameView)
        self.gameView = gameView
        
        
        var playerShip = PlayerShip()
        playerShip.scaleShape(scale: 20)
        playerShip.transform = FloatPoint(gameView.width / 2,
                                          gameView.height / 2)
        gameView.addObject(playerShip, layer: 0)
        addControls()
        
        super.startTest()
    }
    
    // End Test
    override func endTest() {
        super.endTest()
        leftView.removeGestureRecognizer(leftPan)
        rightView.removeGestureRecognizer(rightPan)
        leftView.removeFromSuperview()
        rightView.removeFromSuperview()
        leftControl = .zero
        rightControl = .zero
        gameView.removeFromSuperview()
    }
    
    // Add Controls
    private func addControls() {
        
        // Left View
        let leftView = UIView()
        leftView.translatesAutoresizingMaskIntoConstraints = false
        gameView.addSubview(leftView)
        NSLayoutConstraint.activate([
            leftView.topAnchor.constraint(equalTo: gameView.topAnchor),
            leftView.leadingAnchor.constraint(equalTo: gameView.leadingAnchor),
            leftView.widthAnchor.constraint(equalTo: gameView.widthAnchor, multiplier: 0.5),
            leftView.bottomAnchor.constraint(equalTo: gameView.bottomAnchor)
        ])
        self.leftView = leftView
        
        let leftPan = UIPanGestureRecognizer(target: self, action: #selector(leftPanMoved))
        leftView.addGestureRecognizer(leftPan)
        self.leftPan = leftPan
        
        // Right View
        let rightView = UIView()
        rightView.translatesAutoresizingMaskIntoConstraints = false
        gameView.addSubview(rightView)
        NSLayoutConstraint.activate([
            rightView.topAnchor.constraint(equalTo: gameView.topAnchor),
            rightView.leadingAnchor.constraint(equalTo: leftView.trailingAnchor),
            rightView.trailingAnchor.constraint(equalTo: gameView.trailingAnchor),
            rightView.bottomAnchor.constraint(equalTo: gameView.bottomAnchor)
        ])
        self.rightView = rightView
        
        let rightPan = UIPanGestureRecognizer(target: self, action: #selector(rightPanMoved))
        rightView.addGestureRecognizer(rightPan)
        self.rightPan = rightPan
    }
}

extension Test1: GameViewDelegate1 {
    
    // Update
    func update(_ completion: @escaping () -> Void) {
        for (index, object) in gameView.objects.enumerated() {
            if var playerShip = object as? PlayerShip {
                playerShip.update(velocity: FloatPoint(leftControl))
                gameView.objects[index] = playerShip
            }
        }
        completion()
    }
}
