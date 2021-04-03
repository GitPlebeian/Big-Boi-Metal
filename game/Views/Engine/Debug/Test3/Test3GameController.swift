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
    
    var map: Test3MapLayer = Test3MapLayer()
    var testLayer: Test3TestLayer = Test3TestLayer()
    var grid: Test3GridLayer = Test3GridLayer()
    var textureTest: Test3TextureTest = Test3TextureTest()
    
    var gridOn: Bool = false
    
    // MARK: Init
    
    init(view: GameView3) {
        self.view = view
        
        map.controller = self
        grid.controller = self
        view.addLayer(map, atLayer: 0)
        view.addLayer(grid, atLayer: 1)
//        view.addLayer(textureTest, atLayer: 2)
    }
    
    // MARK: Deinit
    
    deinit {
        print("Test3Game Controller: Deinit")
    }
    
    // MARK: Public
    
    // Tapped
    func tapped(_ location: CGPoint) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
        
        var floatLocation = FloatPoint(location)
        floatLocation = view.getAdjustedPointInCordinateSpace(point: floatLocation, realWorldY: true)
        
        let chunk = getCurrentChunk(location: FloatPoint(location))
        
        map.addChunk(chunk)
        
        let seeableXCells = view.width / map.cellSize * view.vertexScale * 2
        
        print("\nScale: \(view.vertexScale) || Seeable Cells: \(seeableXCells)")
    }
    
    
    // MARK: Helpers
    
    // Get Seeable Chunks
    private func getSeeableChunks() -> [IntCordinate] {
        
        var chunksNeeded: [IntCordinate] = []
        
        let visibleCellsX = (view.width / map.cellSize * view.vertexScale).rounded(.up)
        let visibleCellsY = (view.height / map.cellSize * view.vertexScale).rounded(.up)
        
        var chunksNeededX = Int((visibleCellsX / Float(map.chunkSize)).rounded(.up) + 2)
        if chunksNeededX % 2 == 1 {
            chunksNeededX -= 1
        }
        var chunksNeededY = Int((visibleCellsY / Float(map.chunkSize)).rounded(.up) + 2)
        if chunksNeededY % 2 == 1 {
            chunksNeededY -= 1
        }
        
        var currentChunk = getCurrentChunk()
        
        currentChunk.x += chunksNeededX / 2
        currentChunk.y += chunksNeededY / 2
        
        for xChunk in 0..<chunksNeededX + 1 {
            for yChunk in 0..<chunksNeededY + 1 {
                let chunk = IntCordinate(currentChunk.x - chunksNeededX + xChunk,
                                         currentChunk.y - chunksNeededY + yChunk)
                chunksNeeded.append(chunk)
            }
        }
        return chunksNeeded
    }
    
    // Get Current Chunk
    private func getCurrentChunk(location: FloatPoint? = nil) -> IntCordinate {
        var adjustedLocation: FloatPoint
        if let location = location {
            adjustedLocation = view.getAdjustedPointInCordinateSpace(point: FloatPoint(location.x, location.y), realWorldY: true)
        } else {
            adjustedLocation = view.getAdjustedPointInCordinateSpace(point: FloatPoint(view.width / 2, view.height / 2), realWorldY: true)
        }
        let x = Int((adjustedLocation.x / 2 * view.width / map.cellSize / Float(map.chunkSize)).rounded(.down))
        let y = Int((adjustedLocation.y / 2 * view.height / map.cellSize / Float(map.chunkSize)).rounded(.down))
        return IntCordinate(x, y)
    }
    
    // Get Cell
    private func getCell(_ location: FloatPoint) -> Cell {
        let adjustedPoint = view.getAdjustedPointInCordinateSpace(point: location, realWorldY: true)
        let xCell = Int((adjustedPoint.x / 2 * view.width / map.cellSize).rounded(.down))
        let yCell = Int((adjustedPoint.y / 2 * view.height / map.cellSize).rounded(.down))
        return Cell(x: xCell, y: yCell)
    }
    
    // Print Cordinate
    private func printCellCordinates(_ location: FloatPoint) {
        var cell = getCell(location)
        if cell.x < 0 {
            cell.x = map.chunkSize - (abs(cell.x) % map.chunkSize)
        } else {
            cell.x = cell.x % map.chunkSize
        }
        if cell.y < 0 {
            cell.y = map.chunkSize - (abs(cell.y) % map.chunkSize)
        } else {
            cell.y = cell.y % map.chunkSize
        }
        let chunk = getCurrentChunk(location: location)
        print("Chunk: \(chunk.x) | \(chunk.y) :: Cell: \(cell.x) | \(cell.y)")
    }
}