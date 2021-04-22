//
//  SelectMapViewController.swift
//  Island Hopper
//
//  Created by Jackson Tubbs on 4/11/21.
//

import UIKit

class SelectMapViewController: UIViewController {

    // MARK: Properties
    
    // MARK: Subviews
    
    weak var backButton: UIButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: Deinit
    
    deinit {
        print("Select Map Deinit")
    }
    
    // MARK: Actions
    
    // Back Button Tapped
    @objc private func backButtonTapped() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let initialViewController = InitialViewController()
        window?.rootViewController = initialViewController
    }
    
    // Select Map Tapped
    @objc private func selectMapTapped(_ sender: SelectMapButton) {
        let url = sender.mapName
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        let playViewController = PlayViewController()
        playViewController.mapURL = url
        window?.rootViewController = playViewController
    }
    
    // MARK: Public
    
    // MARK: Private
    
    // MARK: Setup Views
    
    private func setupViews() {
        
        view.backgroundColor = .background1
        
        let backButton = UIButton()
        backButton.backgroundColor = .primary
        backButton.layer.cornerRadius = 8
        backButton.titleLabel?.font = UIFont(name: Text.robotoBold, size: 14)
        backButton.titleLabel?.textColor = .white
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 200),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        self.backButton = backButton
        
        // Scroll View
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // process files
            var buttons: [SelectMapButton] = []
            for (index, url) in fileURLs.enumerated() {
                let button = SelectMapButton(mapName: url)
                button.addTarget(self, action: #selector(selectMapTapped(_:)), for: .touchUpInside)
                button.backgroundColor = .primary
                button.layer.cornerRadius = 8
                button.titleLabel?.text = url.lastPathComponent
                button.titleLabel?.font = UIFont(name: Text.robotoBold, size: 12)
                button.titleLabel?.textColor = .white
                button.setTitle(url.lastPathComponent, for: .normal)
                button.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(button)
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.333333, constant: -10.66666),
                    button.heightAnchor.constraint(equalToConstant: 44)
                ])
                if index == 0 {
                    button.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
                } else if index % 3 == 0 {
                    button.topAnchor.constraint(equalTo: buttons[index - 3].bottomAnchor, constant: 16).isActive = true
                    
                } else {
                    button.topAnchor.constraint(equalTo: buttons[index - 1].topAnchor).isActive = true
                }
                if index % 3 == 2 {
                    button.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
                }
                if index % 3 == 0 {
                    button.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
                } else {
                    button.leadingAnchor.constraint(equalTo: buttons[index - 1].trailingAnchor, constant: 16).isActive = true
                }
                buttons.append(button)
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
}
