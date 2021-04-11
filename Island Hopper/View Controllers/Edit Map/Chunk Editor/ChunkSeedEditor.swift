import UIKit

class ChunkSeedEditor: UIView {

    // MARK: Properties

    weak var map: MapLayer!

    // MARK: Views

    weak var valueParentView: UIView!
    weak var valueTextField:  UITextField!
    weak var randomizeButton: UIButton!

    // MARK: Init

    init(map: MapLayer) {
        self.map = map
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Actions

    // Update Seed
    @objc private func updateSeed() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        valueTextField.resignFirstResponder()

        guard let text = valueTextField.text else {return}

        guard let seed = Int32(text) else {
            print("💩💩💩: Seed Invalid")
            return
        }

        map.seed = seed
        map.updateNoiseSource()
        map.reloadMap()
    }

    // Randomize Seed
    @objc private func randomizeSeed() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()

        let seed = Int32.random(in: 0...Int32.max)
        valueTextField.text = "\(seed)"

        map.seed = seed
        map.updateNoiseSource()
        map.reloadMap()
    }

    // MARK: Public

    // MARK: Helpers

    // MARK: Setup Views

    private func setupViews() {

        // Value Parent View
        let valueParentView = UIView()
        valueParentView.backgroundColor = .background2
        valueParentView.layer.cornerRadius = 8
        valueParentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueParentView)
        NSLayoutConstraint.activate([
            valueParentView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            valueParentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            valueParentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            valueParentView.heightAnchor.constraint(equalToConstant: 40)
        ])
        self.valueParentView = valueParentView

        // Value Text Field Toolbar
        let bar = UIToolbar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        let reset = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(updateSeed))
        bar.items = [reset]
        bar.sizeToFit()

        // Value Text Toolbar
        let valueTextField = UITextField()
        valueTextField.font = UIFont(name: Text.robotoBold, size: 14)
        valueTextField.textColor = .white
        valueTextField.text = "0"
        valueTextField.keyboardType = .numberPad
        valueTextField.textAlignment = .center
        valueTextField.inputAccessoryView = bar
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        valueParentView.addSubview(valueTextField)
        NSLayoutConstraint.activate([
            valueTextField.topAnchor.constraint(equalTo: valueParentView.topAnchor),
            valueTextField.leadingAnchor.constraint(equalTo: valueParentView.leadingAnchor),
            valueTextField.trailingAnchor.constraint(equalTo: valueParentView.trailingAnchor),
            valueTextField.bottomAnchor.constraint(equalTo: valueParentView.bottomAnchor)
        ])
        self.valueTextField = valueTextField

        // Randomize Button
        let randomizeButton = UIButton()
        randomizeButton.titleLabel?.font = UIFont(name: Text.robotoBold, size: 14)
        randomizeButton.titleLabel?.textColor = .white
        randomizeButton.setTitle("Random Seed", for: .normal)
        randomizeButton.backgroundColor = .primary
        randomizeButton.addTarget(self, action: #selector(randomizeSeed), for: .touchUpInside)
        randomizeButton.layer.cornerRadius = 8
        randomizeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(randomizeButton)
        NSLayoutConstraint.activate([
            randomizeButton.topAnchor.constraint(equalTo: valueParentView.bottomAnchor, constant: 8),
            randomizeButton.leadingAnchor.constraint(equalTo: valueParentView.leadingAnchor),
            randomizeButton.trailingAnchor.constraint(equalTo: valueParentView.trailingAnchor),
            randomizeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            randomizeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.randomizeButton = randomizeButton
    }
}
