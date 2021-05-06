//
//  MapLocationHelper.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/5/21.
//

import UIKit

class MapLocationHelper {
    
    // MARK: Properties
    
    weak var controller: PlayController!
    
    // MARK: Init
    
    init(controller: PlayController) {
        self.controller = controller
    }
    
    // Get Cell For Location
    func getCellForLocation(location: CGPoint) -> IntCordinate {
        let adjustedPoint = controller.touchController.getAdjustedPointInCordinateSpace(point: FloatPoint(location), realWorldY: true)
        let xCell = Int((adjustedPoint.x / 2 * controller.touchController.width / controller.mapLayer.cellSize).rounded(.down))
        let yCell = Int((adjustedPoint.y / 2 * controller.touchController.height / controller.mapLayer.cellSize).rounded(.down))
        return IntCordinate(xCell, yCell)
    }
}
