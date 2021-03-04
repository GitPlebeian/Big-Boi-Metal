//
//  Test2.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import UIKit


class Test2: GameViewDebugTest {
 
    // MARK: Views
    
    weak var gameView: GameView2!
    
    // Start Test
    override func startTest() {
        
        let gameView = GameView2(frame: UIScreen.main.bounds)
        gameView.translatesAutoresizingMaskIntoConstraints = false
        debugView.superview!.addSubview(gameView)
        self.gameView = gameView
        
        super.startTest()
    }
    
    // End Test
    override func endTest() {
        super.endTest()

        gameView.removeFromSuperview()
    }
}
