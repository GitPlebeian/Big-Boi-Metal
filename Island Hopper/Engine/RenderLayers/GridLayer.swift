import UIKit
import Metal

class GridLayer: RenderLayer {

    // MARK: Properties

    weak var touchController: EngineTouchController!
    weak var map: MapLayer!

    var gridColor: UIColor = .black

    private var vertices: [Float] = [-1, 1, 1, -1]

    init(map: MapLayer,
         touchController: EngineTouchController) {
        self.map = map
        self.touchController = touchController
        super.init()
    }
    
    // MARK: Rendering

    override func setPipelineState() {
        self.pipelineState = RenderPipelineStateLibrary.shared.pipelineState(.Grid)
    }

    override func render(_ encoder: MTLRenderCommandEncoder) {

        encoder.setRenderPipelineState(pipelineState)

        var transform = touchController.vertexTransform
        var scale     = touchController.vertexScale
        var width     = touchController.width
        var height    = touchController.height
        var gridSize  = map.cellSize
        var color     = (Float(gridColor.redValue),
                         Float(gridColor.greenValue),
                         Float(gridColor.blueValue),
                         Float(1))

        calculateVertices()

        let vertexBuffer = GraphicsDevice.Device.makeBuffer(bytes: vertices, length: vertices.count * 4, options: [])

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBytes(&transform, length: 8, index: 1)
        encoder.setVertexBytes(&scale, length: 4, index: 2)
        encoder.setVertexBytes(&width, length: 4, index: 3)
        encoder.setVertexBytes(&height, length: 4, index: 4)
        encoder.setVertexBytes(&gridSize, length: 4, index: 5)
        encoder.setVertexBytes(&color, length: 16, index: 6)
        encoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertices.count / 2)
    }

    // MARK: Helpers

    // Calculate Vertices
    func calculateVertices() {

//        guard let controller = controller else {return}

        vertices = []

        let visibleXCells = touchController.width / map.cellSize * touchController.vertexScale
        let xStep: Float = 2 / Float(visibleXCells)
        let visibleYCells = touchController.height / map.cellSize * touchController.vertexScale
        let yStep: Float = 2 / Float(visibleYCells)

        let transformX = touchController.vertexTransform.0.truncatingRemainder(dividingBy: xStep)
        let transformY = touchController.vertexTransform.1.truncatingRemainder(dividingBy: yStep)

        for xIndex in 0..<Int(visibleXCells + 3) {
            if xIndex % 2 == 0 {
                let x = xStep * Float(xIndex / 2)
                vertices.append(contentsOf: [0 - x + transformX, 1, 0 - x + transformX, -1])
            } else {
                let x = xStep * Float(xIndex / 2)
                vertices.append(contentsOf: [0 + x + transformX, 1, 0 + x + transformX, -1])
            }
        }
        for yIndex in 0..<Int(visibleYCells + 3) {
            if yIndex % 2 == 0 {
                let y = yStep * Float(yIndex / 2)
                vertices.append(contentsOf: [-1, 0 + y - transformY, 1, 0 + y - transformY])
            } else {
                let y = yStep * Float(yIndex / 2)
                vertices.append(contentsOf: [-1, 0 - y - transformY, 1, 0 - y - transformY])
            }
        }
    }
}
