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
    
    // MARK: Init
    
    init(view: GameView3) {
        self.view = view
        
        map.controller = self
        
        view.addLayer(map, atLayer: 0)
        
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
        
        updateMap()
    }
    
    // Update Map
    func updateMap() {
        let seeableChunks = getSeeableChunks()
        
        map.clearChunks()
        for chunk in seeableChunks {
            map.addChunk(chunk)
        }
    }
    
    // MARK: Helpers
    
    // Get Seeable Chunks
    private func getSeeableChunks() -> [Chunk] {
        
        var chunksNeeded: [Chunk] = []
        
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
                let chunk = Chunk(x: currentChunk.x - chunksNeededX + xChunk,
                                  y: currentChunk.y - chunksNeededY + yChunk)
                chunksNeeded.append(chunk)
            }
        }
        return chunksNeeded
    }
    
    // Get Current Chunk
    private func getCurrentChunk() -> Chunk {
        let location = view.getAdjustedPointInCordinateSpace(point: FloatPoint(view.width / 2, view.height / 2), realWorldY: true)
        let x = Int((location.x / 2 * view.width / Float(map.chunkSize) / map.cellSize))
        let y = Int((location.y / 2 * view.height / Float(map.chunkSize) / map.cellSize))
        return Chunk(x: x, y: y)
    }
    
    // Get Cell
    private func getCell(_ location: FloatPoint) -> Cell {
        let xCell = Int((location.x / 2 * view.width / map.cellSize).rounded(.down))
        let yCell = Int((location.y / 2 * view.height / map.cellSize).rounded(.down))
        return Cell(x: xCell, y: yCell)
    }
}
