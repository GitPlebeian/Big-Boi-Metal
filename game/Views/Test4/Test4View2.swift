//
//  Test4View2.swift
//  game
//
//  Created by Jackson Tubbs on 12/6/20.
//

import UIKit

enum Position {
    case none
    case left
    case right
}

//struct ColorSet {
//    var red: Float
//    var green: Float
//    var blue: Float
//}

class Test4View2: UIView {
    
    // MARK: Properties
    
    var gridWidth: Int = 120
    var colors: [Float] = []
    var ages: [Int] = []
    var maxAge: Int = 200
    var upsTimer: Timer?
    
    // MARK: Subviews
    
    private weak var display: Test4View!
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup Display
        let display = Test4View(gridWidth: gridWidth)
        display.delegate = self
        display.translatesAutoresizingMaskIntoConstraints = false
        addSubview(display)
        NSLayoutConstraint.activate([
            display.topAnchor.constraint(equalTo: topAnchor),
            display.leadingAnchor.constraint(equalTo: leadingAnchor),
            display.trailingAnchor.constraint(equalTo: trailingAnchor),
            display.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.display = display
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Public Functions
    
    // End Game
    func endGame() {
        upsTimer?.invalidate()
        display.endGame()
    }
    
    // Reset
    func reset() {
        display.reset()
    }
    
    // Test
    func test() {
        
    }
    
    // New Grid
    func newGrid() {
        colors = []
    }
    
    // MARK: Helpers
    
    // Reset Colors
    private func resetColors() {
        colors = []
        ages = []
        for _ in 0..<display.getCellCount() {
//            let random = Int.random(in: 0..<2)
//            if random == 0 {
//                colors.append(contentsOf: [1, 1, 1])
//            } else {
//                colors.append(contentsOf: [0.071, 0.071, 0.071])
//            }
            colors.append(contentsOf: [0.071, 0.071, 0.071])
            ages.append(0)
        }
        upsTimer?.invalidate()
        startUPS(ups: 60)
    }
    
    // Start UPS
    private func startUPS(ups: Int) {
        let timer = Timer(timeInterval: 1 / TimeInterval(ups), repeats: true) { (timer) in
            for index in 0..<self.display.getCellCount() {
                if self.ages[index] == 0 {
                    continue
                }
                if self.ages[index] + 1 <= self.maxAge {
                    self.ages[index] += 1
                } else {
                    self.ages[index] = 0
                }
            }
            
            var newColors: [Float] = []
            for y in 0..<self.display.getGridHeight() {
                for x in 0..<self.display.getGridWidth() {
                    if let rightIndex = self.getIndexForCordinates(x: x, y: y, position: .right) {
                        if self.colors[rightIndex] == 0.961 {
                            newColors.append(contentsOf: [0.961, 0.235, 0.235])
                            self.ages[y * self.display.getGridWidth() + x] = 1
                        } else {
                            newColors.append(contentsOf: self.ageColor(index: y * self.display.getGridWidth() + x, color: .white))
                        }
                    } else {
                        newColors.append(contentsOf: self.ageColor(index: y * self.display.getGridWidth() + x, color: .white))
                    }
                }
            }
            
            self.colors = newColors
//            let queue = DispatchQueue(label: "update-grid")
//            queue.async { [weak self] in
//                guard let self = self else {return}
//            }
        }
        RunLoop.main.add(timer, forMode: .common)
        upsTimer = timer
    }
    
    private func ageColor(index: Int, color: UIColor) -> [Float] {
        var newColors: [Float] = []
        
        let agePercent = Float(ages[index]) / Float(maxAge)
        
        if agePercent == 0 {
            return [0.071, 0.071, 0.071]
        }
        
        var red: Float
        var green: Float
        var blue: Float
        
        if agePercent <= 0.5 {
            red = 1 * (0.961 - agePercent * 2) + 0.235 * agePercent * 2
            green = 1 * (0.235 - agePercent * 2) + 0.961 * agePercent * 2
            blue = 1 * (0.235 - agePercent * 2) + 0.235 * agePercent * 2
        } else {
            red = 0.235 * (1.0 - (agePercent - 0.5) * 2) + 0.071 * (agePercent - 0.5) * 2
            green = 0.961 * (1.0 - (agePercent - 0.5) * 2) + 0.071 * (agePercent - 0.5) * 2
            blue = 0.235 * (1.0 - (agePercent - 0.5) * 2) + 0.071 * (agePercent - 0.5) * 2
        }
        
        newColors.append(red)
        newColors.append(green)
        newColors.append(blue)
        return newColors
    }
    
    // Set Color For Cordinates
    private func setColorForCordinates(x: Int, y: Int, color: [Float]) {
        let index = getAjustedIndexForCordinates(x: x, y: y)
        colors[index] = color[0]
        colors[index + 1] = color[1]
        colors[index + 2] = color[2]
    }
    
    // Get Adjusted Index For Cordinates
    private func getAjustedIndexForCordinates(x: Int, y: Int) -> Int {
        let y = display.getGridHeight() - y - 1
        let index = y * display.getGridWidth() + x
        return index * 3
    }
    
    
    // Get Index For Cordinate
    private func getIndexForCordinates(x: Int, y: Int, position: Position = .none) -> Int? {
        var index: Int
        switch position {
        case .none:
            index = y * display.getGridWidth() + x
        case .left:
            if x == 0 {
                return nil
            }
            index = y * display.getGridWidth() + x - 1
        case .right:
            if x >= display.getGridWidth() - 1 {
                return nil
            }
            index = y * display.getGridWidth() + x + 1
        }
        return index * 3
    }
}

extension Test4View2: Test4ViewDelegate {
    func getColors() -> [Float] {
        if colors.count == 0 {
            resetColors()
        }
        return colors
    }
    
    func tapped(x: Int, y: Int) {
        setColorForCordinates(x: x, y: y, color: [0.961, 0.235, 0.235])
        let y = display.getGridHeight() - y - 1
        let index = y * display.getGridWidth() + x
        ages[index] = 1
    }
}
