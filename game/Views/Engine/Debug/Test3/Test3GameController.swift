//
//  Test3GameController.swift
//  game
//
//  Created by Jackson Tubbs on 3/4/21.
//

import UIKit

class Test3GameController {

    // MARK: Properties
    
    weak var view: GameView3!
    
    var map: Test3Map = Test3Map()
    
    // MARK: Init
    
    init(view: GameView3) {
        self.view = view
        
        map.transform = FloatPoint(view.width / 2,
                                   view.height / 2)
        map.addChunk(0, 0)
        
        view.addObject(map, layer: 0)
    }
    
    // MARK: Public
    
    // Tapped
    func tapped(_ location: CGPoint) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
//        let location = getAdjustedPointInCordinateSpace(point: FloatPoint(tapGesture.location(in: self)))
//        print("\nLocation: \(location)")
//        let xCube = (location.x) / 2 * Float(defaultGridWidth)
//        let yCube = (location.y) / 2 * Float(yGridHeight)
//        print("X Cube:   \(Int(xCube.rounded(.up)))")
//        print("Y Cube:   \(Int(yCube.rounded(.up)))")
    }
    
    // Panned
    
    // MARK: Helpers
    
    
}
