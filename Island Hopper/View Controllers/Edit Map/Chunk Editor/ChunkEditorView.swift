
import UIKit

class ChunkEditorView: UIView {

    // MARK: Properties

    var open: Bool = false
    
    weak var map: MapLayer!
    weak var controller: MapEditorController!
    weak var editorView: MapEditorView!
    
    // MARK: Views

    weak var toggleButton: UIButton!
    weak var scrollView:   UIScrollView!
    weak var fadeEditor:   ChunkFadeEditor!
    weak var seedEditor:   ChunkSeedEditor!


    // MARK: Constraints
    var toggleButtonTopConstraint: NSLayoutConstraint!
    var toggleButtonLeadingConstraint: NSLayoutConstraint!
    var toggleButtonTrailingConstraint: NSLayoutConstraint!
    var toggleButtonHeightConstraint: NSLayoutConstraint!

    // MARK: Init

    init(map: MapLayer, editorView: MapEditorView) {
//        self.gameController = controller
//        self.gameView = gameView
        self.editorView = editorView
        self.map = map
        super.init(frame: .zero)
        addToggleButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Actions

    // Toggle View
    @objc private func toggleView() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        editorView.toggleChunkEditor()
    }

    // MARK: Public

    // Open
    func openView() {
        toggleButtonLeadingConstraint.isActive = false
        toggleButtonLeadingConstraint = toggleButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        toggleButtonLeadingConstraint.isActive = true

        toggleButtonTrailingConstraint.isActive = false
        toggleButtonTrailingConstraint = toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        toggleButtonTrailingConstraint.isActive = true

        toggleButtonHeightConstraint.isActive = false
        toggleButtonHeightConstraint = toggleButton.heightAnchor.constraint(equalToConstant: 44)
        toggleButtonHeightConstraint.isActive = true

        toggleButtonTopConstraint.isActive = false
        toggleButtonTopConstraint = toggleButton.topAnchor.constraint(equalTo: topAnchor, constant: 8)
        toggleButtonTopConstraint.isActive = true

        setupViews()
    }

    // Close
    func closeView() {
        toggleButtonLeadingConstraint.isActive = false
        toggleButtonLeadingConstraint = toggleButton.leadingAnchor.constraint(equalTo: leadingAnchor)
        toggleButtonLeadingConstraint.isActive = true

        toggleButtonTrailingConstraint.isActive = false
        toggleButtonTrailingConstraint = toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        toggleButtonTrailingConstraint.isActive = true

        toggleButtonHeightConstraint.isActive = false
        toggleButtonHeightConstraint = toggleButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        toggleButtonHeightConstraint.isActive = true

        toggleButtonTopConstraint.isActive = false
        toggleButtonTopConstraint = toggleButton.topAnchor.constraint(equalTo: topAnchor)
        toggleButtonTopConstraint.isActive = true

        removeViews()
    }

    // MARK: Helpers

    // Remove Views
    private func removeViews() {
        for subview in subviews {
            if subview != toggleButton {
                subview.removeFromSuperview()
            }
        }
    }

    // Add Toggle Button
    private func addToggleButton() {

        // Toggle Button
        let toggleButton = UIButton()
        toggleButton.layer.cornerRadius = 8
        toggleButton.backgroundColor = .primary
        toggleButton.addTarget(self, action: #selector(toggleView), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toggleButton)
        toggleButtonTopConstraint = toggleButton.topAnchor.constraint(equalTo: topAnchor)
        toggleButtonLeadingConstraint = toggleButton.leadingAnchor.constraint(equalTo: leadingAnchor)
        toggleButtonTrailingConstraint = toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        toggleButtonHeightConstraint = toggleButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        NSLayoutConstraint.activate([
            toggleButtonTopConstraint,
            toggleButtonLeadingConstraint,
            toggleButtonTrailingConstraint,
            toggleButtonHeightConstraint
        ])
        self.toggleButton = toggleButton
    }

    // MARK: Setup Views

    private func setupViews() {

        // Scroll View
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        let scrollViewTrailingAnchor = scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        scrollViewTrailingAnchor.priority = .defaultHigh
        let scrollViewLeadingAnchor = scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        scrollViewLeadingAnchor.priority = .defaultHigh
        let scrollViewBottomAnchor = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        scrollViewBottomAnchor.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 8),
            scrollViewTrailingAnchor,
            scrollViewLeadingAnchor,
            scrollViewBottomAnchor
        ])
        self.scrollView = scrollView

        // Fade Editor
        let fadeEditor = ChunkFadeEditor(map: map)
        fadeEditor.backgroundColor = .background1
        fadeEditor.layer.cornerRadius = 8
        fadeEditor.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(fadeEditor)
        NSLayoutConstraint.activate([
            fadeEditor.topAnchor.constraint(equalTo: scrollView.topAnchor),
            fadeEditor.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            fadeEditor.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            fadeEditor.widthAnchor.constraint(equalTo: widthAnchor, constant: -16)
        ])
        self.fadeEditor = fadeEditor

        // Seed Editor
        let seedEditor = ChunkSeedEditor(map: map)
        seedEditor.backgroundColor = .background1
        seedEditor.layer.cornerRadius = 8
        seedEditor.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(seedEditor)
        NSLayoutConstraint.activate([
            seedEditor.topAnchor.constraint(equalTo: fadeEditor.bottomAnchor, constant: 8),
            seedEditor.leadingAnchor.constraint(equalTo: fadeEditor.leadingAnchor),
            seedEditor.trailingAnchor.constraint(equalTo: fadeEditor.trailingAnchor),
            seedEditor.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            seedEditor.widthAnchor.constraint(equalTo: fadeEditor.widthAnchor)
        ])
        self.seedEditor = seedEditor
    }
}
