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
    
    weak var playMapView:       PlayMapView!
    weak var engine:            Engine!
    weak var touchController:   EngineTouchController!
    var      cardDock:          CardDockView!
    var      alertController:   AlertController!
    var      entityPlacer:      EntityPlacer!
    var      mapLocationHelper: MapLocationHelper!
    var      orderQueue:        OrderQueue!
    
    var mapLayer:           MapLayer!
    var gridLayer:          GridLayer!
    var celledTextureLayer: CelledTextureLayer!
    var entityController:   EntityController!
    var network:            PlayNetwork!
    var debugView:          DebugView!
    
    var currentPlayer: Int!
    var gameUUID: String = ""
    var gameStep: Int = 0
    var gameTickTime: TimeInterval = 0.1
    
    var serverStep: Int = 0
    var serverCommandTimer: Timer?
    
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
        
        self.alertController = AlertController(controller: self, playMapView: playMapView)
        
        self.orderQueue = OrderQueue(controller: self)
        
        self.debugView = DebugView(controller: self, playView: playMapView)
        
        engine.addLayer(mapLayer, atLayer: 0)
        engine.addLayer(gridLayer, atLayer: 1)
        engine.addLayer(celledTextureLayer, atLayer: 2)
        
        setupTilesetTexture()
    }
    // MARK: DEINIT
    
    deinit {
        print("Play Controller DEINIT")
    }
    
    // MARK: Public
    
    // Update
    
    // Step Game
    func stepGame(receivedMoves: ReceivedMoves? = nil) {
        
        debugView.stopWaitingForServerMoves()
        
        defer {
            serverStep += 1
        }
        
        debugView.stepLabel.text = "Step: \(serverStep)"
        
        guard let moves = receivedMoves else {
//            print("Stepping Game: \(serverStep). Sending Empty Moves")
            self.network.sendMoves(bundle: self.orderQueue.getMovesBundle())
            let timer = Timer.scheduledTimer(withTimeInterval: network.serverTickTime, repeats: false) { [weak self] timer in
                timer.invalidate()
                guard let self = self else {return}
//                print("Empty Moves Timer Fired: Calling StepGameIfApplicable(). Step: \(self.serverStep)")
                self.serverCommandTimer = nil
                self.stepGameIfApplicable()
            }
            self.serverCommandTimer?.invalidate()
            self.serverCommandTimer = timer
            RunLoop.main.add(serverCommandTimer!, forMode: .common)
            
            return
        }
        
        entityController.update()
        
        for move in moves.playerOneMoves.moves {
            let entity = Entity.getEntityTypeForID(id: move.entityID)
            entity.position = IntCordinate(Int(move.cordX), Int(move.cordY))
            entityController.addEntity(entity: entity)
        }
        for move in moves.playerTwoMoves.moves {
            let entity = Entity.getEntityTypeForID(id: move.entityID)
            entity.position = IntCordinate(Int(move.cordX), Int(move.cordY))
            entityController.addEntity(entity: entity)
        }
//        print("Stepping Game: \(serverStep). Sending Moves From Get Moves Bundle")
        self.network.sendMoves(bundle: self.orderQueue.getMovesBundle())
        let timer = Timer.scheduledTimer(withTimeInterval: network.serverTickTime, repeats: false) { [weak self] timer in
            timer.invalidate()
            guard let self = self else {return}
//            print("Server Command Timer Fired. Step: \(self.serverStep). Calling Step Game If Applicable")
            self.serverCommandTimer = nil
            self.stepGameIfApplicable()
        }
        self.serverCommandTimer?.invalidate()
        self.serverCommandTimer = timer
        RunLoop.main.add(serverCommandTimer!, forMode: .common)
    }
    
    // Step Game If Applicable
    func stepGameIfApplicable() {
//        print("Stepping Game If Applicable For Step: \(serverStep). Server Command Timer: \(serverCommandTimer != nil)")
        if serverCommandTimer != nil {
            return
        }
        if let moves = orderQueue.nextMoves {
//            print("Calling Step Game. Step: \(serverStep). Moves Step: \(moves.step)")
            stepGame(receivedMoves: moves)
            orderQueue.nextMoves = nil
        } else {
            debugView.startWaitingForServerMoves()
            network.requestPreviousMoves()
        }
    }
    
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
}

extension PlayController: EngineTouchControllerDelegate {
    func tapped(location: FloatPoint) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
}
