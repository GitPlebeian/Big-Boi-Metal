//
//  PlayController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/12/21.
//

import UIKit
import Metal

class PlayController {
    
    var map: Map!
    
    weak var playMapView: PlayMapView!
    weak var engine: Engine!
    weak var touchController: EngineTouchController!
    var      cardDock: CardDockView!
    var entityPlacer: EntityPlacer!
    var mapLocationHelper: MapLocationHelper!
    
    var mapLayer: MapLayer!
    var gridLayer: GridLayer!
    var celledTextureLayer: CelledTextureLayer!
    var entityController: EntityController!
    var network: PlayNetwork!
    
    // MARK: Init
    
    init(engine: Engine,
         touchController: EngineTouchController,
         mapURL: URL,
         playMapView: PlayMapView) {
        
        self.playMapView = playMapView
        self.engine = engine
        self.touchController = touchController
        self.map = loadMap(url: mapURL)
        self.mapLayer = MapLayer(map: self.map,
                                 touchController: touchController)
        self.gridLayer = GridLayer(map: mapLayer,
                                   touchController: touchController)
        
        self.celledTextureLayer = CelledTextureLayer(map: mapLayer,
                                                     touchController: touchController)
        
        self.cardDock = CardDockView(controller: self, playMapView: playMapView)
        cardDock.addCard(card: WarriorCard(controller: self))
        
        self.entityPlacer = EntityPlacer(controller: self)
        
        self.mapLocationHelper = MapLocationHelper(controller: self)
        
        self.entityController = EntityController(controller: self)
        
        self.network = PlayNetwork(controller: self)
        
        engine.addLayer(mapLayer, atLayer: 0)
        engine.addLayer(gridLayer, atLayer: 1)
        engine.addLayer(celledTextureLayer, atLayer: 2)
        
        setupTilesetTexture()
        startUpdate()
    }
    // MARK: DEINIT
    
    deinit {
        print("Play Controller DEINIT")
    }
    
    // MARK: Public
    
    
    
    // MARK: Private
    
    // Load Map
    private func loadMap(url: URL) -> Map {
        do {
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            let mapSave = try jsonDecoder.decode(MapSave.self, from: data)
            return Map(mapSave: mapSave)
        } catch {
            print("Unable To Decode Map From URL")
            return Map()
        }
    }
    
    // Setup Texture
    private func setupTilesetTexture() {
        let image = UIImage(named: "tileset")!
        let imageRef = image.cgImage!

        let tileSetWidth = imageRef.width
        let tilSetHeight = imageRef.height

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: tileSetWidth, height: tilSetHeight, mipmapped: false)
        textureDescriptor.usage = [.shaderRead]
        
        let region = MTLRegionMake2D(0, 0, tileSetWidth, tilSetHeight)

        let pixelData = imageRef.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let texture = GraphicsDevice.Device.makeTexture(descriptor: textureDescriptor)!
        texture.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: tileSetWidth * 4)
        mapLayer.terrainTileTexture = texture
        celledTextureLayer.tileTexure = texture
    }
    
    // Start Update
    private func startUpdate() {
        let timer = Timer(timeInterval: 1, repeats: true) {[weak self] (timer) in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.entityController.update()
        }
        RunLoop.main.add(timer, forMode: .common)
    }
}

extension PlayController: EngineTouchControllerDelegate {
    func tapped(location: FloatPoint) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
}
