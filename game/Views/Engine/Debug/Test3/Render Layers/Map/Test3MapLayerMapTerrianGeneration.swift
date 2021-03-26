//
//  Test3MapLayerMapTerrianGeneration.swift
//  game
//
//  Created by Jackson Tubbs on 3/18/21.
//

import UIKit
import GameKit

extension Test3MapLayer {
    
    // Get Chunk Data
    func getChunkData(_ chunkAddress: ChunkAddress) -> [CellType] {
        
        let chunk = chunkAddress.chunk
        
        let noise = GKNoise(noiseSource)
        
        noise.move(by: SIMD3<Double>(Double(chunk.x), 0, Double(chunk.y)))
        
        
        let noiseMap = GKNoiseMap(noise,
                                  size: SIMD2<Double>(arrayLiteral: 1, 1),
                                  origin: SIMD2(arrayLiteral: 0, 0),
                                  sampleCount: SIMD2<Int32>(Int32(Int(chunkSize + 1)), Int32(chunkSize + 1)),
                                  seamless: true)
        
        let fadeLengthInset = fadeLength
        
        var types: [CellType] = []
        for y in 0..<chunkSize + 1 {
            for x in 0..<chunkSize + 1 {
                
                var value = noiseMap.value(at: SIMD2<Int32>(Int32(x), Int32(y)))
                let inverseX = chunkSize - x
                let inverseY = chunkSize - y
                
                if chunkAddress.type == .fadeNorth {
                    let multiplier = -2 * Float(chunkSize - inverseY) / Float(chunkSize)
                    value += multiplier
                } else if chunkAddress.type == .fadeEast {
                    let multiplier = -2 * Float(chunkSize - inverseX) / Float(chunkSize)
                    value += multiplier
                } else if chunkAddress.type == .fadeSouth {
                    let multiplier = -2 * Float(chunkSize - y) / Float(chunkSize)
                    value += multiplier
                } else if chunkAddress.type == .fadeWest {
                    let multiplier = -2 * Float(chunkSize - x) / Float(chunkSize)
                    value += multiplier
                } else if chunkAddress.type == .fadeNorthEast {
                    let multiplierY = -2 * Float(chunkSize - inverseY) / Float(chunkSize)
                    let multiplierX = -2 * Float(chunkSize - inverseX) / Float(chunkSize)
                    if multiplierX > multiplierY {
                        value += multiplierX
                    } else {
                        value += multiplierY
                    }
                } else if chunkAddress.type == .fadeNorthEastBig {
                    let multiplierY = -2 * Float(chunkSize - inverseY) / Float(chunkSize)
                    let multiplierX = -2 * Float(chunkSize - inverseX) / Float(chunkSize)
                    value += multiplierX
                    value += multiplierY
                } else if chunkAddress.type == .fadeSouthEast {
                    let multiplierY = -2 * Float(chunkSize - y) / Float(chunkSize)
                    let multiplierX = -2 * Float(chunkSize - inverseX) / Float(chunkSize)
                    if multiplierX > multiplierY {
                        value += multiplierX
                    } else {
                        value += multiplierY
                    }
                } else if chunkAddress.type == .fadeSouthEastBig {
                    let multiplierY = -2 * Float(chunkSize - y) / Float(chunkSize)
                    let multiplierX = -2 * Float(chunkSize - inverseX) / Float(chunkSize)
                    value += multiplierX
                    value += multiplierY
                } else if chunkAddress.type == .fadeSouthWest {
                    let multiplierY = -2 * Float(chunkSize - y) / Float(chunkSize)
                    let multiplierX = -2 * Float(chunkSize - x) / Float(chunkSize)
                    if multiplierX > multiplierY {
                        value += multiplierX
                    } else {
                        value += multiplierY
                    }
                } else if chunkAddress.type == .fadeSouthWestBig {
                    let multiplierY = -2 * Float(chunkSize - y) / Float(chunkSize)
                    let multiplierX = -2 * Float(chunkSize - x) / Float(chunkSize)
                    value += multiplierX
                    value += multiplierY
                } else if chunkAddress.type == .fadeNorthWest {
                    let multiplierY = -2 * Float(chunkSize - inverseY) / Float(chunkSize)
                    let multiplierX = -2 * Float(chunkSize - x) / Float(chunkSize)
                    if multiplierX > multiplierY {
                        value += multiplierX
                    } else {
                        value += multiplierY
                    }
                } else if chunkAddress.type == .fadeNorthWestBig {
                    let multiplierY = -2 * Float(chunkSize - inverseY) / Float(chunkSize)
                    let multiplierX = -2 * Float(chunkSize - x) / Float(chunkSize)
                    value += multiplierX
                    value += multiplierY
                }
                // Top Left Corner
                else if x < fadeLengthInset && inverseY < fadeLengthInset {
                    if chunkAddress.type == .ignoreNeighbors {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    } else if chunkAddress.hasNeighbor(.west) && chunkAddress.hasNeighbor(.north) && !chunkAddress.hasNeighbor(.northWest) {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        if multiplierX > multiplierY {
                            value += multiplierX
                        } else {
                            value += multiplierY
                        }
                    } else if chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.north) {
                        let multiplier = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.west) && chunkAddress.hasNeighbor(.north) {
                        let multiplier = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.north) {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    }
                }
                // Top Right Corner
                else if inverseX < fadeLengthInset && inverseY < fadeLengthInset {
                    if chunkAddress.type == .ignoreNeighbors {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    } else if chunkAddress.hasNeighbor(.north) && chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.northEast) {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        if multiplierX > multiplierY {
                            value += multiplierX
                        } else {
                            value += multiplierY
                        }
                    } else if chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.north) {
                        let multiplier = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.east) && chunkAddress.hasNeighbor(.north) {
                        let multiplier = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.north) {
                        let multiplierY = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    }
                }
                // Bottom Left Corner
                else if x < fadeLengthInset && y < fadeLengthInset {
                    if chunkAddress.type == .ignoreNeighbors {
                        let multiplierY = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    } else if chunkAddress.hasNeighbor(.south) && chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.southWest) {
                        let multiplierY = -2 * Float(fadeLength - x - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - y + fadeInset) / Float(fadeLength)
                        if multiplierX > multiplierY {
                            value += multiplierX
                        } else {
                            value += multiplierY
                        }
                    } else if chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.south) {
                        let multiplier = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.west) && chunkAddress.hasNeighbor(.south) {
                        let multiplier = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.west) && !chunkAddress.hasNeighbor(.south) {
                        let multiplierY = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - x + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    }
                }
                // Bottom Right Corner
                else if inverseX < fadeLengthInset && y < fadeLengthInset {
                    if chunkAddress.type == .ignoreNeighbors {
                        let multiplierY = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    } else if chunkAddress.hasNeighbor(.south) && chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.southEast) {
                        let multiplierY = -2 * Float(fadeLength - inverseX - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - y + fadeInset) / Float(fadeLength)
                        if multiplierX > multiplierY {
                            value += multiplierX
                        } else {
                            value += multiplierY
                        }
                    } else if chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.south) {
                        let multiplier = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.east) && chunkAddress.hasNeighbor(.south) {
                        let multiplier = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplier
                    } else if !chunkAddress.hasNeighbor(.east) && !chunkAddress.hasNeighbor(.south) {
                        let multiplierY = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                        let multiplierX = -2 * Float(fadeLength - inverseX + fadeInset) / Float(fadeLength)
                        value += multiplierX
                        value += multiplierY
                    }
                }
                // Top
                else if x >= fadeLengthInset && inverseX >= fadeLengthInset && inverseY < fadeLengthInset && (!chunkAddress.hasNeighbor(.north) || chunkAddress.type == .ignoreNeighbors) {
                    let multiplier = -2 * Float(fadeLength - inverseY - fadeInset) / Float(fadeLength)
                    value += multiplier
                }
                // Bottom
                else if x >= fadeLengthInset && inverseX >= fadeLengthInset && y < fadeLengthInset && (!chunkAddress.hasNeighbor(.south) || chunkAddress.type == .ignoreNeighbors) {
                    let multiplier = -2 * Float(fadeLength - y - fadeInset) / Float(fadeLength)
                    value += multiplier
                }
                // Left
                else if y >= fadeLengthInset && inverseY >= fadeLengthInset && x < fadeLengthInset && (!chunkAddress.hasNeighbor(.west) || chunkAddress.type == .ignoreNeighbors) {
                    let multiplier = -2 * Float(fadeLength - x - fadeInset) / Float(fadeLength)
                    value += multiplier
                }
                // Right
                else if y >= fadeLengthInset && inverseY >= fadeLengthInset && inverseX < fadeLengthInset && (!chunkAddress.hasNeighbor(.east) || chunkAddress.type == .ignoreNeighbors) {
                    let multiplier = -2 * Float(fadeLength - inverseX - fadeInset) / Float(fadeLength)
                    value += multiplier
                }
                types.append(getTypeForFloat(value + chunkAddress.valueOffset))
            }
        }
        
        return types
    }
    
    // Update Cell Graphics
    func updateCellGraphics(_ chunkCordinates: [IntCordinate]) {
        
        for chunkCordinate in chunkCordinates {
            
            let address = chunks[chunkCordinate]!
            
            var chunkVertices: [Float] = []
            var chunkColors:   [Float] = []
            
            for mapLevel in CellType.allCases {
                
                let layerColor = getColorForType(mapLevel)
                for index in 0..<chunkSize * chunkSize {
                    
                    let y = index / (chunkSize)
                    
                    // Get Type
                    var config: Int8 = 0
                    
                    var materials: [CellType] = []
                    if !materials.contains(address.types[index + y]) {
                        materials.append(address.types[index + y])
                    }
                    if !materials.contains(address.types[index + y + 1]) {
                        materials.append(address.types[index + y + 1])
                    }
                    if !materials.contains(address.types[index + y + chunkSize + 1]) {
                        materials.append(address.types[index + y + chunkSize + 1])
                    }
                    if !materials.contains(address.types[index + y + chunkSize + 2]) {
                        materials.append(address.types[index + y + chunkSize + 2])
                    }
                    
                    if address.types[index + y] == mapLevel { // Bottom Left
                        config += 2
                    }
                    if address.types[index + 1 + y] == mapLevel { // Bottom Right
                        config += 1
                    }
                    if address.types[index + chunkSize + y + 1] == mapLevel { // Top Left
                        config += 8
                    }
                    if address.types[index + chunkSize + y + 2] == mapLevel { // Top Right
                        config += 4
                    }
                    if materials.count > 2 {
                        
                        var lowestLevel = CellType.allCases.last!
                        var highestLevel = CellType.allCases.first!
                        for material in materials {
                            if material.rawValue < lowestLevel.rawValue {
                                lowestLevel = material
                            }
                            if material.rawValue > highestLevel.rawValue {
                                highestLevel = material
                            }
                        }
                        var middleLevel: CellType = highestLevel
                        for material in materials {
                            if material != lowestLevel && material != highestLevel && material.rawValue < middleLevel.rawValue {
                                middleLevel = material
                            }
                        }
                        if mapLevel == middleLevel {
                            let filler = getFillerForMultipleMaterials(fill: mapLevel,
                                                                       corners: [address.types[index + chunkSize + y + 1],
                                                                                 address.types[index + chunkSize + y + 2],
                                                                                 address.types[index + 1 + y],
                                                                                 address.types[index + y]],
                                                                       chunk: address.chunk,
                                                                       index: index,
                                                                       layerColor: layerColor)
                            chunkVertices.append(contentsOf: filler.0)
                            chunkColors.append(contentsOf: filler.1)
                        }
                    }
                    let vertexAndColors = getVertexAndColorsForConfig(config, index: index, chunk: address.chunk, color: layerColor)
                    
                    chunkVertices.append(contentsOf: vertexAndColors.0)
                    chunkColors.append(contentsOf: vertexAndColors.1)
                }
            }

            var vertexStartIndex: Int = 0
            var colorStartIndex: Int = 0
            
            for chunk in chunks {
                if chunk.value.index < chunks[chunkCordinate]!.index {
                    vertexStartIndex += chunk.value.vertexCount
                    colorStartIndex += chunk.value.colorCount
                }
            }
            
            vertices.replaceSubrange(vertexStartIndex..<vertexStartIndex + address.vertexCount, with: chunkVertices)
            colors.replaceSubrange(colorStartIndex..<colorStartIndex + address.colorCount, with: chunkColors)
            
            chunks[chunkCordinate]!.vertexCount = chunkVertices.count
            chunks[chunkCordinate]!.colorCount = chunkColors.count
        }
    }
    
    // Get Config For Multiple Materials
    func getFillerForMultipleMaterials(fill:        CellType,
                                       corners:     [CellType],
                                       chunk:       IntCordinate,
                                       index:       Int,
                                       layerColor:  UIColor) -> ([Float], [Float]) {

        let x = Float(index % chunkSize + chunkSize * chunk.x)
        let y = Float(index / chunkSize + chunkSize * chunk.y)
        
        let tmx = x + 0.5 // Top M
        let tmy = y + 1
        let mlx = x // Middle L
        let mly = y + 0.5
        let mrx = x + 1 // Middle R
        let mry = y + 0.5
        let bmx = x + 0.5 // Bottom Middle
        let bmy = y + 0
        
        // Top Left And Right
        if corners[0] == corners[2] {
            return ([], [])
        } else if corners[1] == corners[3] {
            return ([], [])
        }
        // Whole Empty
        var accountedTypes: [CellType] = []
        for cellType in corners {
            if !accountedTypes.contains(cellType) {
                accountedTypes.append(cellType)
            }
        }
        if accountedTypes.count == 4 {
            let vertices: [Float] = [tmx, tmy,
                                     mrx, mry,
                                     bmx, bmy,
                                     tmx, tmy,
                                     bmx, bmy,
                                     mlx, mly]
            var colors: [Float] = []
            
            for _ in 0..<vertices.count / 2 {
                colors.append(contentsOf: [Float(layerColor.redValue),
                                           Float(layerColor.greenValue),
                                           Float(layerColor.blueValue)])
            }
            return (vertices,
                    colors)
        }
        var vertices: [Float] = []
        var colors: [Float] = []
        for (index, cellType) in corners.enumerated() {
            var forwardIndex = index + 1
            if forwardIndex == corners.count {
                forwardIndex = 0
            }
            if cellType == corners[forwardIndex] && index == 0 {
                vertices.append(contentsOf: [mlx, mly, mrx, mry, bmx, bmy])
            } else if cellType == corners[forwardIndex] && index == 1 {
                vertices.append(contentsOf: [tmx, tmy, bmx, bmy, mlx, mly])
            } else if cellType == corners[forwardIndex] && index == 2 {
                vertices.append(contentsOf: [tmx, tmy, mrx, mry, mlx, mly])
            } else if cellType == corners[forwardIndex] && index == 3 {
                vertices.append(contentsOf: [tmx, tmy, mrx, mry, bmx, bmy])
            }
        }
        
        for _ in 0..<vertices.count / 2 {
            colors.append(contentsOf: [Float(layerColor.redValue),
                                       Float(layerColor.greenValue),
                                       Float(layerColor.blueValue)])
        }
        return (vertices,
                colors)
    }
    
    // Update Chunk Colors
    func tintChunkColors(color: UIColor, strength: Float, cordinate: IntCordinate) {
        var colorStartIndex: Int = 0
        
        for chunk in chunks {
            if chunk.value.index < chunks[cordinate]!.index {
                colorStartIndex += chunk.value.colorCount
            }
        }
        
        for colorIndex in colorStartIndex..<colorStartIndex + chunks[cordinate]!.colorCount {
            let mod = colorIndex % 3
            switch mod {
            case 0: colors[colorIndex] += Float(color.redValue) * strength
            case 1: colors[colorIndex] += Float(color.greenValue) * strength
            case 2: colors[colorIndex] += Float(color.blueValue) * strength
            default: break
            }
        }
    }
    
    // Get Vertex And Colors For Config
    func getVertexAndColorsForConfig(_ config: Int8, index: Int, chunk: IntCordinate, color: UIColor) -> ([Float],[Float]) {
        
        let x = Float(index % chunkSize + chunkSize * chunk.x)
        let y = Float(index / chunkSize + chunkSize * chunk.y)
        
        let tlx = x // Top L
        let tly = y + 1
        let tmx = x + 0.5 // Top M
        let tmy = y + 1
        let trx = x + 1 // Top R
        let trY = y + 1
        
        let mlx = x // Middle L
        let mly = y + 0.5
        let mrx = x + 1
        let mry = y + 0.5
        
        let blx = x
        let bly = y + 0
        let bmx = x + 0.5
        let bmy = y + 0
        let brx = x + 1
        let bry = y + 0
        
        var vertexs: [Float] = []
        var colors: [Float] = []
        switch config {
        case 1:  vertexs = [bmx, bmy, mrx, mry, brx, bry]
        case 2:  vertexs = [mlx, mly, bmx, bmy, blx, bly]
        case 3:  vertexs = [mlx, mly, brx, bry, blx, bly, mlx, mly, mrx, mry, brx, bry]
        case 4:  vertexs = [tmx, tmy, trx, trY, mrx, mry]
        case 5:  vertexs = [tmx, tmy, trx, trY, bmx, bmy, trx, trY, brx, bry, bmx, bmy]
        case 6:  vertexs = [tmx, tmy, trx, trY, mlx, mly, trx, trY, blx, bly, mlx, mly, trx, trY, bmx, bmy, blx, bly, trx, trY, mrx, mry, bmx, bmy]
        case 7:  vertexs = [tmx, tmy, blx, bly, mlx, mly, tmx, tmy, brx, bry, blx, bly, tmx, tmy, trx, trY, brx, bry]
        case 8:  vertexs = [tlx, tly, tmx, tmy, mlx, mly]
        case 9:  vertexs = [tlx, tly, bmx, bmy, mlx, mly, tlx, tly, brx, bry, bmx, bmy, tlx, tly, mrx, mry, brx, bry, tlx, tly, tmx, tmy, mrx, mry]
        case 10: vertexs = [tlx, tly, tmx, tmy, bmx, bmy, tlx, tly, bmx, bmy, blx, bly]
        case 11: vertexs = [tlx, tly, tmx, tmy, blx, bly, tmx, tmy, brx, bry, blx, bly, tmx, tmy, mrx, mry, brx, bry]
        case 12: vertexs = [tlx, tly, mrx, mry, mlx, mly, tlx, tly, trx, trY, mrx, mry]
        case 13: vertexs = [tlx, tly, bmx, bmy, mlx, mly, tlx, tly, trx, trY, bmx, bmy, trx, trY, brx, bry, bmx, bmy]
        case 14: vertexs = [tlx, tly, bmx, bmy, blx, bly, tlx, tly, trx, trY, bmx, bmy, trx, trY, mrx, mry, bmx, bmy]
        case 15: vertexs = [tlx, tly, brx, bry, blx, bly, tlx, tly, trx, trY, brx, bry]
        default: break
        }
        
        for _ in 0..<vertexs.count / 2 {
            colors.append(contentsOf: [Float(color.redValue),
                                       Float(color.greenValue),
                                       Float(color.blueValue)])
        }
        
        return (vertexs, colors)
    }
    
    
    
    // Get Type For Float
    func getTypeForFloat(_ number: Float) -> CellType {
        if number <= -0.99 {
            return .darkSea
        } else if number <= -0.8 {
            return .superDeepWater
        } else if number <= -0.6 {
            return .deepWater
        } else if number <= -0.4 {
            return .water
        } else if number <= -0.2 {
            return .shallowWater
        } else if number <= 0 {
            return .beach
        } else if number <= 0.3 {
            return .grass
        } else if number <= 0.55 {
            return .forest
        } else if number <= 0.65 {
            return .mountain1
        } else if number <= 0.75 {
            return .mountain2
        } else if number <= 0.85 {
            return .mountain3
        } else if number <= 0.95 {
            return .mountain4
        } else {
            return .snow
        }
    }
    
    // Get Color For Type
    func getColorForType(_ type: CellType) -> UIColor {
        switch type {
        case .darkSea: return .mapDarkSea
        case .superDeepWater: return .mapSuperDeepWater
        case .deepWater: return .mapDeepWater
        case .water: return .mapWater
        case .shallowWater: return .mapShallowWater
        case .beach: return .mapBeach
        case .grass: return .mapGrass
        case .forest: return .mapForest
        case .mountain1: return .mapMountain1
        case .mountain2: return .mapMountain2
        case .mountain3: return .mapMountain3
        case .mountain4: return .mapMountain4
        case .snow: return .mapSnow
        }
    }
}
