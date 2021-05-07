//
//  CardView.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 5/4/21.
//

import UIKit

protocol CardViewDelegate: class {
    func didStartPan()
    func panEnded()
}

class CardView: UIView {

    // MARK: Properties
    
    weak var delegate: CardViewDelegate?
    
    let card: Card
    
    // MARK: Subviews
    
    // MARK: Gestures
    
    private weak var panGesture: UIPanGestureRecognizer!
    private weak var tapGesture: UITapGestureRecognizer!
    
    // MARK: Init
    
    init(card: Card) {
        self.card = card
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        print("Card View DEINIT")
    }
    
    // MARK: Actions
    @objc private func panned() {
        if panGesture.state == .began {
            delegate?.didStartPan()
            card.startedPlacingBlock(panGesture.location(in: nil))
        } else if panGesture.state == .failed || panGesture.state == .cancelled {
            delegate?.panEnded()
            card.placingCancelled()
        } else if panGesture.state == .ended {
            delegate?.panEnded()
            card.placedCard(panGesture.location(in: nil))
        } else {
            card.placingPannedBlock(panGesture.location(in: nil))
        }
    }
    
    @objc private func tapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    // MARK: Public
    
    // MARK: Private
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        backgroundColor = .primary
        layer.cornerRadius = 8
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned))
        addGestureRecognizer(panGesture)
        self.panGesture = panGesture
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
}
