//
//  Test3.swift
//  game
//
//  Created by Jackson Tubbs on 3/3/21.
//

import UIKit

// Perlin Test
class Test3: GameViewDebugTest {
    
    // MARK: Properties
    
    var previousOctavesValue: Int!
    
    // MARK: Views
    
    weak var gameView:         GameView3!
    
    weak var frequencyView:          UIView!
    weak var frequencySliderLabel:   UILabel!
    weak var frequencySlider:        UISlider!
    
    weak var octaveView:             UIView!
    weak var octaveSliderLabel:      UILabel!
    weak var octaveSlider:           UISlider!
    
    weak var persistenceView:        UIView!
    weak var persistenceSliderLabel: UILabel!
    weak var persistenceSlider:      UISlider!
    
    weak var lacunarityView:         UIView!
    weak var lacunaritySliderLabel:  UILabel!
    weak var lacunaritySlider:       UISlider!

    // MARK: Actions

    // Frequency Changed
    @objc private func frequencySliderChanged() {
        let value = (frequencySlider.value * 100).rounded() / 100
        frequencySliderLabel.text = "Frequency: \(value)"
        gameView.test3GameController.map.frequency = Double(value)
        gameView.test3GameController.map.updateNoiseSource()
        gameView.test3GameController.map.reloadMap()
    }
    
    // Octave Changed
    @objc private func octaveSliderChanged() {
        let value = (octaveSlider.value).rounded()
        octaveSlider.value = value
        octaveSliderLabel.text = "Octaves: \(Int(value))"
        if previousOctavesValue == nil {
            previousOctavesValue = Int(value)
            gameView.test3GameController.map.octaveCount = Int(value)
            gameView.test3GameController.map.updateNoiseSource()
        }
        if Int(value) == previousOctavesValue {
            return
        }
        previousOctavesValue = Int(value)
        gameView.test3GameController.map.octaveCount = Int(value)
        gameView.test3GameController.map.updateNoiseSource()
        gameView.test3GameController.map.reloadMap()
    }
    
    // Persistence Changed
    @objc private func persistenceSliderChanged() {
        let value = (persistenceSlider.value * 100).rounded() / 100
        persistenceSliderLabel.text = "Persistence: \(value)"
        gameView.test3GameController.map.persistence = Double(value)
        gameView.test3GameController.map.updateNoiseSource()
        gameView.test3GameController.map.reloadMap()
    }
    
    // Lacunarity Change
    @objc private func lacunaritySliderChanged() {
        let value = (lacunaritySlider.value * 100).rounded() / 100
        lacunaritySliderLabel.text = "Lacunarity: \(value)"
        gameView.test3GameController.map.lacunarity = Double(value)
        gameView.test3GameController.map.updateNoiseSource()
        gameView.test3GameController.map.reloadMap()
    }
    
    
    // MARK: Helpers
    
    // Start Test
    override func startTest() {
        
        let gameView = GameView3(frame: UIScreen.main.bounds)
        gameView.delegate = self
        let gameViewSuperView = debugView.superview!
        gameViewSuperView.addSubview(gameView)
        self.gameView = gameView
        
        setupViews()
        
        super.startTest()
    }
    
    // End Test
    override func endTest() {
        super.endTest()
        gameView.removeFromSuperview()
        previousOctavesValue = nil
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        // Frequency View
        let frequencyView = UIView()
        frequencyView.backgroundColor = .primary
        frequencyView.layer.cornerRadius = debugView.elementCornerRadius
        addViewToScrollView(view: frequencyView, below: testToggleButton)
        self.frequencyView = frequencyView
        
        // Frequency Slider Label
        let frequencySliderLabel = UILabel()
        frequencySliderLabel.font = UIFont(name: UIFont.robotoBold, size: 12)
        frequencySliderLabel.textColor = .white
        frequencySliderLabel.translatesAutoresizingMaskIntoConstraints = false
        frequencyView.addSubview(frequencySliderLabel)
        NSLayoutConstraint.activate([
            frequencySliderLabel.topAnchor.constraint(equalTo: frequencyView.topAnchor, constant: debugView.contentSpacing),
            frequencySliderLabel.leadingAnchor.constraint(equalTo: frequencyView.leadingAnchor, constant: debugView.contentSpacing)
        ])
        self.frequencySliderLabel = frequencySliderLabel
        
        // Frequency Slider
        let frequencySlider = UISlider()
        frequencySlider.minimumValue = 0
        frequencySlider.maximumValue = 4
        frequencySlider.value = 1.0
        frequencySlider.addTarget(self, action: #selector(frequencySliderChanged), for: .valueChanged)
        frequencySlider.translatesAutoresizingMaskIntoConstraints = false
        frequencyView.addSubview(frequencySlider)
        NSLayoutConstraint.activate([
            frequencySlider.topAnchor.constraint(equalTo: frequencySliderLabel.bottomAnchor, constant: debugView.contentSpacing),
            frequencySlider.leadingAnchor.constraint(equalTo: frequencyView.leadingAnchor, constant: debugView.contentSpacing),
            frequencySlider.trailingAnchor.constraint(equalTo: frequencyView.trailingAnchor, constant: -debugView.contentSpacing),
            frequencySlider.bottomAnchor.constraint(equalTo: frequencyView.bottomAnchor, constant: -debugView.contentSpacing)
        ])
        self.frequencySlider = frequencySlider
        
        // Octave View
        let octaveView = UIView()
        octaveView.backgroundColor = .primary
        octaveView.layer.cornerRadius = debugView.elementCornerRadius
        addViewToScrollView(view: octaveView, below: frequencyView)
        self.octaveView = octaveView
        
        // Octave Slider Label
        let octaveSliderLabel = UILabel()
        octaveSliderLabel.font = UIFont(name: UIFont.robotoBold, size: 12)
        octaveSliderLabel.textColor = .white
        octaveSliderLabel.translatesAutoresizingMaskIntoConstraints = false
        octaveView.addSubview(octaveSliderLabel)
        NSLayoutConstraint.activate([
            octaveSliderLabel.topAnchor.constraint(equalTo: octaveView.topAnchor, constant: debugView.contentSpacing),
            octaveSliderLabel.leadingAnchor.constraint(equalTo: octaveView.leadingAnchor, constant: debugView.contentSpacing)
        ])
        self.octaveSliderLabel = octaveSliderLabel
        
        // Octave Slider
        let octaveSlider = UISlider()
        octaveSlider.minimumValue = 1
        octaveSlider.maximumValue = 6
        octaveSlider.value = 6
        octaveSlider.addTarget(self, action: #selector(octaveSliderChanged), for: .valueChanged)
        octaveSlider.translatesAutoresizingMaskIntoConstraints = false
        octaveView.addSubview(octaveSlider)
        NSLayoutConstraint.activate([
            octaveSlider.topAnchor.constraint(equalTo: octaveSliderLabel.bottomAnchor, constant: debugView.contentSpacing),
            octaveSlider.leadingAnchor.constraint(equalTo: octaveView.leadingAnchor, constant: debugView.contentSpacing),
            octaveSlider.trailingAnchor.constraint(equalTo: octaveView.trailingAnchor, constant: -debugView.contentSpacing),
            octaveSlider.bottomAnchor.constraint(equalTo: octaveView.bottomAnchor, constant: -debugView.contentSpacing)
        ])
        self.octaveSlider = octaveSlider
        
        // Persistence View
        let persistenceView = UIView()
        persistenceView.backgroundColor = .primary
        persistenceView.layer.cornerRadius = debugView.elementCornerRadius
        addViewToScrollView(view: persistenceView, below: octaveView)
        self.persistenceView = persistenceView
        
        // Persistence Slider Label
        let persistenceSliderLabel = UILabel()
        persistenceSliderLabel.font = UIFont(name: UIFont.robotoBold, size: 12)
        persistenceSliderLabel.textColor = .white
        persistenceSliderLabel.translatesAutoresizingMaskIntoConstraints = false
        persistenceView.addSubview(persistenceSliderLabel)
        NSLayoutConstraint.activate([
            persistenceSliderLabel.topAnchor.constraint(equalTo: persistenceView.topAnchor, constant: debugView.contentSpacing),
            persistenceSliderLabel.leadingAnchor.constraint(equalTo: persistenceView.leadingAnchor, constant: debugView.contentSpacing)
        ])
        self.persistenceSliderLabel = persistenceSliderLabel
        
        // Persistence Slider
        let persistenceSlider = UISlider()
        persistenceSlider.minimumValue = 0
        persistenceSlider.maximumValue = 1
        persistenceSlider.value = 0.52
        persistenceSlider.addTarget(self, action: #selector(persistenceSliderChanged), for: .valueChanged)
        persistenceSlider.translatesAutoresizingMaskIntoConstraints = false
        persistenceView.addSubview(persistenceSlider)
        NSLayoutConstraint.activate([
            persistenceSlider.topAnchor.constraint(equalTo: persistenceSliderLabel.bottomAnchor, constant: debugView.contentSpacing),
            persistenceSlider.leadingAnchor.constraint(equalTo: persistenceView.leadingAnchor, constant: debugView.contentSpacing),
            persistenceSlider.trailingAnchor.constraint(equalTo: persistenceView.trailingAnchor, constant: -debugView.contentSpacing),
            persistenceSlider.bottomAnchor.constraint(equalTo: persistenceView.bottomAnchor, constant: -debugView.contentSpacing)
        ])
        self.persistenceSlider = persistenceSlider
        
        // Lacunarity View
        let lacunarityView = UIView()
        lacunarityView.backgroundColor = .primary
        lacunarityView.layer.cornerRadius = debugView.elementCornerRadius
        addViewToScrollView(view: lacunarityView, below: persistenceView)
        self.lacunarityView = lacunarityView
        
        // Lacunarity Slider Label
        let lacunaritySliderLabel = UILabel()
        lacunaritySliderLabel.font = UIFont(name: UIFont.robotoBold, size: 12)
        lacunaritySliderLabel.textColor = .white
        lacunaritySliderLabel.translatesAutoresizingMaskIntoConstraints = false
        lacunarityView.addSubview(lacunaritySliderLabel)
        NSLayoutConstraint.activate([
            lacunaritySliderLabel.topAnchor.constraint(equalTo: lacunarityView.topAnchor, constant: debugView.contentSpacing),
            lacunaritySliderLabel.leadingAnchor.constraint(equalTo: lacunarityView.leadingAnchor, constant: debugView.contentSpacing)
        ])
        self.lacunaritySliderLabel = lacunaritySliderLabel
        
        // Lacunarity Slider
        let lacunaritySlider = UISlider()
        lacunaritySlider.minimumValue = 0
        lacunaritySlider.maximumValue = 3
        lacunaritySlider.value = 1.91
        lacunaritySlider.addTarget(self, action: #selector(lacunaritySliderChanged), for: .valueChanged)
        lacunaritySlider.translatesAutoresizingMaskIntoConstraints = false
        lacunarityView.addSubview(lacunaritySlider)
        NSLayoutConstraint.activate([
            lacunaritySlider.topAnchor.constraint(equalTo: lacunaritySliderLabel.bottomAnchor, constant: debugView.contentSpacing),
            lacunaritySlider.leadingAnchor.constraint(equalTo: lacunarityView.leadingAnchor, constant: debugView.contentSpacing),
            lacunaritySlider.trailingAnchor.constraint(equalTo: lacunarityView.trailingAnchor, constant: -debugView.contentSpacing),
            lacunaritySlider.bottomAnchor.constraint(equalTo: lacunarityView.bottomAnchor, constant: -debugView.contentSpacing)
        ])
        self.lacunaritySlider = lacunaritySlider
        
        
        frequencySliderChanged()
        octaveSliderChanged()
        persistenceSliderChanged()
        lacunaritySliderChanged()
    }
}

extension Test3: GameViewDelegate3 {

}
