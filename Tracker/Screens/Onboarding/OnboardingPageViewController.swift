//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 24/05/2024.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    // MARK: - Properties
    
    let page: OnboardingPage
    
    // MARK: - UI Components
    
    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView(image: UIImage(named: page.imageName))
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImageView
    }()
    
    private lazy var textLabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.boldSystemFont(ofSize: 32)
        textLabel.textAlignment = .center
        textLabel.textColor = .black
        textLabel.backgroundColor = .clear
        textLabel.text = page.title
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    // MARK: - Initialization
    
    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageContent()
    }
    
    // MARK: - Setup Methods
    
    private func setupPageContent() {
        view.addSubview(backgroundImageView)
        view.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
