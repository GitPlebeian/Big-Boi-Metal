//
//  TileHelper.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/22/21.
//

import Foundation

class TileHelper {
    
    // Get Tile For Direction
    static func getTileForDirection(tile: TileType, graphicType: TileGraphicType) -> IntCordinate {
        
        switch tile {
        case .beach:
            switch graphicType {
            case .topLeft:            return IntCordinate(0, 0)
            case .top:                return IntCordinate(1, 0)
            case .topRight:           return IntCordinate(2, 0)
            case .left:               return IntCordinate(0, 1)
            case .whole:              return IntCordinate(1, 1)
            case .right:              return IntCordinate(2, 1)
            case .bottomLeft:         return IntCordinate(0, 2)
            case .bottom:             return IntCordinate(1, 2)
            case .bottomRight:        return IntCordinate(2, 2)
            case .topLeftMissing:     return IntCordinate(0, 3)
            case .topRightMissing:    return IntCordinate(1,3)
            case .bottomLeftMissing:  return IntCordinate(0, 4)
            case .bottomRightMissing: return IntCordinate(1, 4)
            case .diagonalTRBL:       return IntCordinate(2, 3)
            case .diagonalTLBR:       return IntCordinate(2, 4)
            }
        case .shallowWater:
            switch graphicType {
            case .topLeft:            return IntCordinate(3, 0)
            case .top:                return IntCordinate(4, 0)
            case .topRight:           return IntCordinate(5, 0)
            case .left:               return IntCordinate(3, 1)
            case .whole:              return IntCordinate(4, 1)
            case .right:              return IntCordinate(5, 1)
            case .bottomLeft:         return IntCordinate(3, 2)
            case .bottom:             return IntCordinate(4, 2)
            case .bottomRight:        return IntCordinate(5, 2)
            case .topLeftMissing:     return IntCordinate(3, 3)
            case .topRightMissing:    return IntCordinate(4, 3)
            case .bottomLeftMissing:  return IntCordinate(3, 4)
            case .bottomRightMissing: return IntCordinate(4, 4)
            case .diagonalTRBL:       return IntCordinate(5, 3)
            case .diagonalTLBR:       return IntCordinate(5, 4)
            }
        case .water:
            switch graphicType {
            case .topLeft:            return IntCordinate(0, 5)
            case .top:                return IntCordinate(1, 5)
            case .topRight:           return IntCordinate(2, 5)
            case .left:               return IntCordinate(0, 6)
            case .whole:              return IntCordinate(1, 6)
            case .right:              return IntCordinate(2, 6)
            case .bottomLeft:         return IntCordinate(0, 7)
            case .bottom:             return IntCordinate(1, 7)
            case .bottomRight:        return IntCordinate(2, 7)
            case .topLeftMissing:     return IntCordinate(0, 8)
            case .topRightMissing:    return IntCordinate(1, 8)
            case .diagonalTRBL:       return IntCordinate(2, 8)
            case .bottomLeftMissing:  return IntCordinate(0, 9)
            case .bottomRightMissing: return IntCordinate(1, 9)
            case .diagonalTLBR:       return IntCordinate(2, 9)
            }
        case .forest:
            switch graphicType {
            case .topLeft:            return IntCordinate(18, 10)
            case .top:                return IntCordinate(16, 10)
            case .topRight:           return IntCordinate(19, 10)
            case .left:               return IntCordinate(17, 9)
            case .whole:
                let tiles = [(15, 4), (16, 4), (17, 4), (18, 4), (15, 5), (16, 5), (17, 5), (18, 5), (15, 6), (16, 6), (17, 6), (18, 6), (15, 7), (16, 7), (17, 7), (18, 7)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .right:              return IntCordinate(15, 9)
            case .bottomLeft:         return IntCordinate(18, 11)
            case .bottom:             return IntCordinate(16, 8)
            case .bottomRight:        return IntCordinate(19, 11)
            case .topLeftMissing:     return IntCordinate(17, 10)
            case .topRightMissing:    return IntCordinate(15, 10)
            case .diagonalTRBL:       return IntCordinate(18, 8)
            case .bottomLeftMissing:  return IntCordinate(17, 8)
            case .bottomRightMissing: return IntCordinate(15, 8)
            case .diagonalTLBR:       return IntCordinate(18, 9)
            }
        case .mountain1:
            switch graphicType {
            case .topLeft:            return IntCordinate(12, 0)
            case .top:                return IntCordinate(13, 0)
            case .topRight:           return IntCordinate(14, 0)
            case .left:               return IntCordinate(12, 1)
            case .whole:              return IntCordinate(13, 1)
            case .right:              return IntCordinate(14, 1)
            case .bottomLeft:         return IntCordinate(12, 2)
            case .bottom:             return IntCordinate(13, 2)
            case .bottomRight:        return IntCordinate(14, 2)
            case .topLeftMissing:     return IntCordinate(12, 3)
            case .topRightMissing:    return IntCordinate(13, 3)
            case .diagonalTRBL:       return IntCordinate(14, 3)
            case .bottomLeftMissing:  return IntCordinate(12, 4)
            case .bottomRightMissing: return IntCordinate(13, 4)
            case .diagonalTLBR:       return IntCordinate(14, 4)
            }
        case .mountain2:
            switch graphicType {
            case .topLeft:            return IntCordinate(12, 5)
            case .top:                return IntCordinate(13, 5)
            case .topRight:           return IntCordinate(14, 5)
            case .left:               return IntCordinate(12, 6)
            case .whole:              return IntCordinate(13, 6)
            case .right:              return IntCordinate(14, 6)
            case .bottomLeft:         return IntCordinate(12, 7)
            case .bottom:             return IntCordinate(13, 7)
            case .bottomRight:        return IntCordinate(14, 7)
            case .topLeftMissing:     return IntCordinate(12, 8)
            case .topRightMissing:    return IntCordinate(13, 8)
            case .diagonalTRBL:       return IntCordinate(14, 8)
            case .bottomLeftMissing:  return IntCordinate(12, 9)
            case .bottomRightMissing: return IntCordinate(13, 9)
            case .diagonalTLBR:       return IntCordinate(14, 9)
            }
        case .mountain3:
            switch graphicType {
            case .topLeft:            return IntCordinate(0, 10)
            case .top:                return IntCordinate(1, 10)
            case .topRight:           return IntCordinate(2, 10)
            case .left:               return IntCordinate(0, 11)
            case .whole:              return IntCordinate(1, 11)
            case .right:              return IntCordinate(2, 11)
            case .bottomLeft:         return IntCordinate(0, 12)
            case .bottom:             return IntCordinate(1, 12)
            case .bottomRight:        return IntCordinate(2, 12)
            case .topLeftMissing:     return IntCordinate(0, 13)
            case .topRightMissing:    return IntCordinate(1, 13)
            case .diagonalTRBL:       return IntCordinate(2, 13)
            case .bottomLeftMissing:  return IntCordinate(0, 14)
            case .bottomRightMissing: return IntCordinate(1, 14)
            case .diagonalTLBR:       return IntCordinate(2, 14)
            }
        case .mountain4:
            switch graphicType {
            case .topLeft:            return IntCordinate(3, 10)
            case .top:                return IntCordinate(4, 10)
            case .topRight:           return IntCordinate(5, 10)
            case .left:               return IntCordinate(3, 11)
            case .whole:              return IntCordinate(4, 11)
            case .right:              return IntCordinate(5, 11)
            case .bottomLeft:         return IntCordinate(3, 12)
            case .bottom:             return IntCordinate(4, 12)
            case .bottomRight:        return IntCordinate(5, 12)
            case .topLeftMissing:     return IntCordinate(3, 13)
            case .topRightMissing:    return IntCordinate(4, 13)
            case .diagonalTRBL:       return IntCordinate(5, 13)
            case .bottomLeftMissing:  return IntCordinate(3, 14)
            case .bottomRightMissing: return IntCordinate(4, 14)
            case .diagonalTLBR:       return IntCordinate(5, 14)
            }
        case .snow:
            switch graphicType {
            case .topLeft:            return IntCordinate(6, 10)
            case .top:                return IntCordinate(7, 10)
            case .topRight:           return IntCordinate(8, 10)
            case .left:               return IntCordinate(6, 11)
            case .whole:              return IntCordinate(7, 11)
            case .right:              return IntCordinate(8, 11)
            case .bottomLeft:         return IntCordinate(6, 12)
            case .bottom:             return IntCordinate(7, 12)
            case .bottomRight:        return IntCordinate(8, 12)
            case .topLeftMissing:     return IntCordinate(6, 13)
            case .topRightMissing:    return IntCordinate(7, 13)
            case .diagonalTRBL:       return IntCordinate(8, 13)
            case .bottomLeftMissing:  return IntCordinate(6, 14)
            case .bottomRightMissing: return IntCordinate(7, 14)
            case .diagonalTLBR:       return IntCordinate(8, 14)
            }
        case .deepWater:
            switch graphicType {
            case .topLeft:            return IntCordinate(3, 5)
            case .top:                return IntCordinate(4, 5)
            case .topRight:           return IntCordinate(5, 5)
            case .left:               return IntCordinate(3, 6)
            case .whole:              return IntCordinate(4, 6)
            case .right:              return IntCordinate(5, 6)
            case .bottomLeft:         return IntCordinate(3, 7)
            case .bottom:             return IntCordinate(4, 7)
            case .bottomRight:        return IntCordinate(5, 7)
            case .topLeftMissing:     return IntCordinate(3, 8)
            case .topRightMissing:    return IntCordinate(4, 8)
            case .diagonalTRBL:       return IntCordinate(5, 8)
            case .bottomLeftMissing:  return IntCordinate(3, 9)
            case .bottomRightMissing: return IntCordinate(4, 9)
            case .diagonalTLBR:       return IntCordinate(5, 9)
            }
        case .superDeepWater:
            switch graphicType {
            case .topLeft:            return IntCordinate(6, 5)
            case .top:                return IntCordinate(7, 5)
            case .topRight:           return IntCordinate(8, 5)
            case .left:               return IntCordinate(6, 6)
            case .whole:              return IntCordinate(7, 6)
            case .right:              return IntCordinate(8, 6)
            case .bottomLeft:         return IntCordinate(6, 7)
            case .bottom:             return IntCordinate(7, 7)
            case .bottomRight:        return IntCordinate(8, 7)
            case .topLeftMissing:     return IntCordinate(6, 8)
            case .topRightMissing:    return IntCordinate(7, 8)
            case .diagonalTRBL:       return IntCordinate(8, 8)
            case .bottomLeftMissing:  return IntCordinate(6, 9)
            case .bottomRightMissing: return IntCordinate(7, 9)
            case .diagonalTLBR:       return IntCordinate(8, 9)
            }
        case .darkSea:
            switch graphicType {
            case .topLeft:            return IntCordinate(9, 5)
            case .top:                return IntCordinate(10, 5)
            case .topRight:           return IntCordinate(11, 5)
            case .left:               return IntCordinate(9, 6)
            case .whole:              return IntCordinate(10, 6)
            case .right:              return IntCordinate(11, 6)
            case .bottomLeft:         return IntCordinate(9, 7)
            case .bottom:             return IntCordinate(10, 7)
            case .bottomRight:        return IntCordinate(11, 7)
            case .topLeftMissing:     return IntCordinate(9, 8)
            case .topRightMissing:    return IntCordinate(10, 8)
            case .diagonalTRBL:       return IntCordinate(11, 8)
            case .bottomLeftMissing:  return IntCordinate(9, 9)
            case .bottomRightMissing: return IntCordinate(10, 9)
            case .diagonalTLBR:       return IntCordinate(11, 9)
            }
        case .grass:
            switch graphicType {
            case .topLeft: return IntCordinate(19,8)
            case .top:
                let tiles = [(19, 0), (20, 0), (21, 0)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .topRight: return IntCordinate(20, 8)
            case .left:
                let tiles = [(19, 3), (20, 3), (21, 3)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .whole:
                let tiles = [(15, 0), (16, 0), (17, 0), (18, 0), (15, 1), (16, 1), (17, 1), (18, 1), (15, 2), (16, 2), (17, 2), (18, 2), (15, 3), (16, 3), (17, 3), (18, 3)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .right:
                let tiles = [(19, 2), (20, 2), (21, 2)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .bottomLeft: return IntCordinate(19, 9)
            case .bottom:
                let tiles = [(19, 1), (20, 1), (21, 1)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .bottomRight: return IntCordinate(20, 9)
            case .topLeftMissing:
                let tiles = [(19, 5), (20, 5), (21, 5)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .topRightMissing:
                let tiles = [(19, 4), (20, 4), (21, 4)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .diagonalTRBL: return IntCordinate(21, 8)
            case .bottomLeftMissing:
                let tiles = [(19, 7), (20, 7), (21, 7)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .bottomRightMissing:
                let tiles = [(19, 6), (20, 6), (21, 6)]
                let tile = tiles.randomElement()!
                return IntCordinate(tile.0, tile.1)
            case .diagonalTLBR: return IntCordinate(21, 9)
            }
        }
    }
}
