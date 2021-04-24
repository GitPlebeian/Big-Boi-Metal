//
//  TileHelper.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/22/21.
//

import Foundation

class TileHelper {
    
    static func getTileForDirection(tile: TileType, graphicType: TileGraphicType) -> IntCordinate {
        
        
        
        switch tile {
        case .beach:
            switch graphicType {
            case .topLeft:
                return IntCordinate(0, 0)
            case .top:
                return IntCordinate(1, 0)
            case .topRight:
                return IntCordinate(2, 0)
            case .left:
                return IntCordinate(0, 1)
            case .whole:
                return IntCordinate(1, 1)
            case .right:
                return IntCordinate(2, 1)
            case .bottomLeft:
                return IntCordinate(0, 2)
            case .bottom:
                return IntCordinate(1, 2)
            case .bottomRight:
                return IntCordinate(2, 2)
            case .topLeftMissing:
                return IntCordinate(0, 3)
            case .topRightMissing: return IntCordinate(1,3)
            case .bottomLeftMissing: return IntCordinate(0, 4)
            case .bottomRightMissing: return IntCordinate(1, 4)
            case .diagonalTRBL: return IntCordinate(2, 3)
            case .diagonalTLBR: return IntCordinate(2, 4)
            }
        case .shallowWater:
            switch graphicType {
            case .topLeft:
                return IntCordinate(3, 0)
            case .top:
                return IntCordinate(4, 0)
            case .topRight:
                return IntCordinate(5, 0)
            case .left:
                return IntCordinate(3, 1)
            case .whole:
                return IntCordinate(4, 1)
            case .right:
                return IntCordinate(5, 1)
            case .bottomLeft:
                return IntCordinate(3, 2)
            case .bottom:
                return IntCordinate(4, 2)
            case .bottomRight:
                return IntCordinate(5, 2)
            case .topLeftMissing: return IntCordinate(3, 3)
            case .topRightMissing: return IntCordinate(4, 3)
            case .bottomLeftMissing: return IntCordinate(3, 4)
            case .bottomRightMissing: return IntCordinate(4, 4)
            case .diagonalTRBL: return IntCordinate(5, 3)
            case .diagonalTLBR: return IntCordinate(5, 4)
            }
        case .grass:
            switch graphicType {
            case .topLeft: return IntCordinate(6,0)
            case .top: return IntCordinate(7, 0)
            case .topRight: return IntCordinate(8, 0)
            case .left: return IntCordinate(6, 1)
            case .whole: return IntCordinate(7, 1)
            case .right: return IntCordinate(8, 1)
            case .bottomLeft: return IntCordinate(6, 2)
            case .bottom: return IntCordinate(7, 2)
            case .bottomRight: return IntCordinate(8, 2)
            case .topLeftMissing: return IntCordinate(6, 3)
            case .topRightMissing: return IntCordinate(7, 3)
            case .diagonalTRBL: return IntCordinate(8, 3)
            case .bottomLeftMissing: return IntCordinate(6, 4)
            case .bottomRightMissing: return IntCordinate(7, 4)
            case .diagonalTLBR: return IntCordinate(8, 4)
            }
        default:
            break
        }
        
        return IntCordinate(0, 8)
    }
}
