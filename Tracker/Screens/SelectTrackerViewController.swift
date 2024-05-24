//
// SelectTrackerViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 24/01/2024.
//

import UIKit

final class SelectTrackerViewController: UIViewController {
    // MARK: - Delegate
    
    weak var delegate: TrackerCreationDelegate?
    
    // MARK: - Properties
    
    var onTrackerCreated: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var eventButton: CustomButton = {
        let button = CustomButton(title: "Нерегулярное событие")
        button.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var habitButton: CustomButton = {
        let button = CustomButton(title: "Привычка")
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside
        )
        return button
    }()
    
    private lazy var titleLabel = CustomTitleLabel(text: "Создание трекера")
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view?.backgroundColor = UIColor(resource: .ypWhiteDay)
        setupUI()
    }
   
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.addSubview(eventButton)
        view.addSubview(habitButton)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            eventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -281),
            habitButton.bottomAnchor.constraint(equalTo: eventButton.topAnchor, constant: -20),
        ])
    }
    
    // MARK: - Navigation
    
    private func presentCreateTrackerViewController(isHabit: Bool) {
        let createTrackerVC = CreateTrackerViewController(isHabit: isHabit)
        createTrackerVC.delegate = delegate
        createTrackerVC.modalPresentationStyle = .pageSheet
        createTrackerVC.onCompletion = { [weak self] in
            self?.dismiss(animated: false, completion: self?.onTrackerCreated)
        }
        present(createTrackerVC, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func habitButtonTapped() {
        presentCreateTrackerViewController(isHabit: true)
    }
    
    @objc private func eventButtonTapped() {
        presentCreateTrackerViewController(isHabit: false)
    }
    
}
