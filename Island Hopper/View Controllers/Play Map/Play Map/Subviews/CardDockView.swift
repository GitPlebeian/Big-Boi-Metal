///
//  CardDockView.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/4/21.
//

import UIKit

class CardDockView: UIView {
    
    // MARK: Properties
    
    weak var    controller: PlayController!
    weak var    playMapView: PlayMapView!
    private var cardViews: [CardView] = []
    private var cards: [Card] = []
    private var currentPage: Int = 0
    
    private var dockOpen: Bool = false
    
    private var didSetBounds: Bool = false
    
    private var cardsPadding: CGFloat = 8
    private var desiredCardWidth: CGFloat = 70
    
    private var didSetupParameters: Bool = false
    private var cardsPerPage: Int!
    private var cardWidth: CGFloat! {
        didSet {
            didSetupParameters = true
            layoutCards()
        }
    }
    
    // MARK: Views
    
    weak var closeDockButton: UIButton!
    weak var openDockButton: UIButton!
    
    weak var dock: UIView!
    weak var cardsView: UIView!
    
    weak var leftButton: UIButton!
    weak var rightButton: UIButton!
    
    // MARK: Constraints
    
    // MARK: Init
    
    init(controller: PlayController,
         playMapView: PlayMapView) {
        self.controller = controller
        self.playMapView = playMapView
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Did Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if didSetBounds == false {
            didSetBounds = true
            setCardParameters()
        }
    }
    
    // MARK: Actions
    
    // Open Dock
    @objc private func openDock() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        dock.isHidden = false
        openDockButton.isHidden = true
        dockOpen = true
    }
    
    // Close Dock
    @objc private func closeDock() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        dock.isHidden = true
        openDockButton.isHidden = false
        dockOpen = false
    }
    
    // Right Tapped
    @objc private func rightTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    // Left Tapped
    @objc private func leftTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    // MARK: Public
    
    // Add Card
    func addCard(card: Card) {
        cards.append(card)
    }
    
    // Layout Cards
    func layoutCards() {
        if didSetupParameters == false {
            return
        }
        for subview in cardsView.subviews {
            subview.removeFromSuperview()
        }
        cardViews = []
        for (index, card) in cards.enumerated() {
            
            if index >= cardsPerPage {
                break
            }
            
            let cardView = CardView(card: card)
            cardView.delegate = self
            cardView.translatesAutoresizingMaskIntoConstraints = false
            cardsView.addSubview(cardView)
            
            if index == 0 {
                cardView.leadingAnchor.constraint(equalTo: cardsView.leadingAnchor, constant: cardsPadding).isActive = true
            } else {
                cardView.leadingAnchor.constraint(equalTo: cardViews[index - 1].trailingAnchor, constant: cardsPadding).isActive = true
            }
            
            NSLayoutConstraint.activate([
                cardView.widthAnchor.constraint(equalToConstant: cardWidth),
                cardView.topAnchor.constraint(equalTo: cardsView.topAnchor, constant: cardsPadding),
                cardView.bottomAnchor.constraint(equalTo: cardsView.bottomAnchor, constant: -cardsPadding)
            ])
            cardViews.append(cardView)
        }
    }
    
    // MARK: Private
    
    // Set Card Parameters
    private func setCardParameters() {
        let cardsViewWidth = cardsView.bounds.width
        var cardsThatFit = cardsViewWidth / (desiredCardWidth + cardsPadding)
        cardsThatFit = cardsThatFit.rounded(.down)
        cardsPerPage = Int(cardsThatFit)
        cardWidth = (cardsViewWidth - (cardsPadding * (cardsThatFit + 1))) / cardsThatFit
    }
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        playMapView.addSubview(self)
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: playMapView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            trailingAnchor.constraint(equalTo: playMapView.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            heightAnchor.constraint(equalToConstant: 44),
            widthAnchor.constraint(equalToConstant: 44)
        ])
        
        // Open Dock Button
        let openDockButton = UIButton()
        openDockButton.backgroundColor = .primary
        openDockButton.layer.cornerRadius = 16
        openDockButton.addTarget(self, action: #selector(openDock), for: .touchUpInside)
        openDockButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(openDockButton)
        NSLayoutConstraint.activate([
            openDockButton.heightAnchor.constraint(equalToConstant: 44),
            openDockButton.widthAnchor.constraint(equalToConstant: 44),
            openDockButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            openDockButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.openDockButton = openDockButton
        
        // Dock
        let dock = UIView()
        dock.backgroundColor = .background2
        dock.layer.cornerRadius = 16
        dock.isHidden = true
        dock.translatesAutoresizingMaskIntoConstraints = false
        playMapView.addSubview(dock)
        NSLayoutConstraint.activate([
            dock.leadingAnchor.constraint(equalTo: playMapView.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            dock.trailingAnchor.constraint(equalTo: playMapView.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            dock.bottomAnchor.constraint(equalTo: playMapView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            dock.heightAnchor.constraint(equalToConstant: 150)
        ])
        self.dock = dock
        
        // Toggle Button
        let closeDockButton = UIButton()
        closeDockButton.backgroundColor = .primary
        closeDockButton.addTarget(self, action: #selector(closeDock), for: .touchUpInside)
        closeDockButton.layer.cornerRadius = 8
        closeDockButton.translatesAutoresizingMaskIntoConstraints = false
        dock.addSubview(closeDockButton)
        NSLayoutConstraint.activate([
            closeDockButton.widthAnchor.constraint(equalToConstant: 44),
            closeDockButton.topAnchor.constraint(equalTo: dock.topAnchor, constant: 8),
            closeDockButton.trailingAnchor.constraint(equalTo: dock.trailingAnchor, constant: -8),
            closeDockButton.bottomAnchor.constraint(equalTo: dock.bottomAnchor, constant: -8)
        ])
        self.closeDockButton = closeDockButton
        
        // Right Button
        let rightButton = UIButton()
        rightButton.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
        rightButton.backgroundColor = .primary
        rightButton.layer.cornerRadius = 8
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        dock.addSubview(rightButton)
        NSLayoutConstraint.activate([
            rightButton.topAnchor.constraint(equalTo: dock.topAnchor, constant: 8),
            rightButton.trailingAnchor.constraint(equalTo: closeDockButton.leadingAnchor, constant: -8),
            rightButton.heightAnchor.constraint(equalTo: dock.heightAnchor, multiplier: 0.5, constant: -12),
            rightButton.widthAnchor.constraint(equalTo: rightButton.heightAnchor)
        ])
        self.rightButton = rightButton
        
        // Left Button
        let leftButton = UIButton()
        leftButton.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        leftButton.backgroundColor = .primary
        leftButton.layer.cornerRadius = 8
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        dock.addSubview(leftButton)
        NSLayoutConstraint.activate([
            leftButton.topAnchor.constraint(equalTo: rightButton.bottomAnchor, constant: 8),
            leftButton.trailingAnchor.constraint(equalTo: rightButton.trailingAnchor),
            leftButton.leadingAnchor.constraint(equalTo: rightButton.leadingAnchor),
            leftButton.heightAnchor.constraint(equalTo: leftButton.widthAnchor)
        ])
        self.leftButton = leftButton
        
        // Cards View
        let cardsView = UIView()
        cardsView.backgroundColor = .background1
        cardsView.layer.cornerRadius = 8
        cardsView.translatesAutoresizingMaskIntoConstraints = false
        dock.addSubview(cardsView)
        NSLayoutConstraint.activate([
            cardsView.topAnchor.constraint(equalTo: dock.topAnchor, constant: 8),
            cardsView.leadingAnchor.constraint(equalTo: dock.leadingAnchor, constant: 8),
            cardsView.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -8),
            cardsView.bottomAnchor.constraint(equalTo: dock.bottomAnchor, constant: -8)
        ])
        self.cardsView = cardsView
    }
}

extension CardDockView: CardViewDelegate {
    
    
    // Pan Ended
    func panEnded() {
        controller.gridLayer.enabled = false
        openDock()
    }
    
    
    // Did Start Pan
    func didStartPan(card: Card) {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        closeDock()
        controller.gridLayer.enabled = true
    }
}
