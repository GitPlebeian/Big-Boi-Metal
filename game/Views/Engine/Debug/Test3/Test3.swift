//
//  Test3.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import UIKit

// Perlin Test
class Test3: GameViewDebugTest {
    
    // MARK: Views
    
    weak var gameView:         GameView3!
    

    // MARK: Actions
    
    // MARK: Helpers
    
    // Start Test
    override func startTest() {
        
        let gameView = GameView3(frame: UIScreen.main.bounds)
        gameView.delegate = self
        let gameViewSuperView = debugView.superview!
        gameViewSuperView.addSubview(gameView)
        self.gameView = gameView
        
        super.startTest()
    }
    
    // End Test
    override func endTest() {
        super.endTest()
        gameView.removeFromSuperview()
    }
}

extension Test3: GameViewDelegate3 {

}
