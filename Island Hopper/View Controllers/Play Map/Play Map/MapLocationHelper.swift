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
    
    // MARK: Deinit
    
    deinit {
        print("Map LocationHelper DEINIT")
    }
    
    // Get Cell For Location
    func getCellForLocation(location: CGPoint) -> IntCordinate {
        let adjustedPoint = controller.touchController.getAdjustedPointInCordinateSpace(point: FloatPoint(location), realWorldY: true)
        let xCell = Int((adjustedPoint.x / 2 * controller.touchController.width / controller.mapLayer.cellSize).rounded(.down))
        let yCell = Int((adjustedPoint.y / 2 * controller.touchController.height / controller.mapLayer.cellSize).rounded(.down))
        return IntCordinate(xCell, yCell)
    }
    
    // Get Whole Type For Cord
    func getWholeTypeForLocation(cord: IntCordinate) -> TileType? {
        if cord.y >= controller.map.height || cord.y < 0  || cord.x < 0 || cord.x >= controller.map.width {
            return nil
        }
        let index = cord.y * controller.map.width + cord.x
        let corners = [controller.map.tiles[index + cord.y],
                       controller.map.tiles[index + cord.y + 1],
                       controller.map.tiles[index + cord.y + controller.map.width + 1],
                       controller.map.tiles[index + cord.y + controller.map.width + 2]]
        
        if corners[0] != corners[1] || corners[0] != corners[2] || corners[0] != corners[3] {
            return nil
        } else {
            return corners[0]
        }
    }
    
    // On Map Cordinates
    func onMapCordinates(cord: IntCordinate) -> Bool {
        if cord.y >= controller.map.height || cord.y < 0  || cord.x < 0 || cord.x >= controller.map.width {
            return false
        } else {
            return true
        }
    }
}
