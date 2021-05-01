//
//  Global Enums.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/11/21.
//

import Foundation

enum AnimationState {
    case open
    case closed
    case animating
}

enum Direction {
    case north
    case west
    case east
    case south
    case northWest
    case northEast
    case southEast
    case southWest
}

enum TileGraphicFillerType {
    case top
    case right
    case bottom
    case left
    case whole
}

enum TileGraphicType {
    case top
    case right
    case bottom
    case left
    case topRight
    case bottomRight
    case bottomLeft
    case topLeft
    case whole
    case diagonalTRBL
    case diagonalTLBR
    case topRightMissing
    case bottomRightMissing
    case bottomLeftMissing
    case topLeftMissing
}
