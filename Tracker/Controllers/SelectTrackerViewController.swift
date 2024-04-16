//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 24/01/2024.
//

import UIKit

class SelectTrackerViewController: UIViewController {    
    // MARK: - Delegate
    
    weak var delegate: TrackerCreationDelegate?
    
    // MARK: - Properties
    
    var onTrackerCreated: (() -> Void)?
    
    // MARK: - UI Components
    
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(UIColor(resource: .ypWhiteDay), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlackDay)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(eventButtonTapped),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var habitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(UIColor(resource: .ypWhiteDay), for: .normal)
        button.backgroundColor = UIColor(resource: .ypBlackDay)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(habitButtonTapped),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textColor = UIColor(resource: .ypBlackDay)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view?.backgroundColor = UIColor(resource: .ypWhiteDay)
        setupUI()
    }
    
    // MARK: - Actions
    
    @objc private func habitButtonTapped() {
presentCreateTrackerViewController(isHabit: true)
    }
    
    @objc private func eventButtonTapped() {
        presentCreateTrackerViewController(isHabit: false)
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
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.addSubview(eventButton)
        view.addSubview(habitButton)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            eventButton.widthAnchor.constraint(equalToConstant: 335),
            eventButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -281),
            
            habitButton.widthAnchor.constraint(equalTo: eventButton.widthAnchor),
            habitButton.heightAnchor.constraint(equalTo: eventButton.heightAnchor),
            habitButton.centerXAnchor.constraint(equalTo: eventButton.centerXAnchor),
            habitButton.bottomAnchor.constraint(equalTo: eventButton.topAnchor, constant: -20),
            
            titleLabel.centerXAnchor.constraint(equalTo: habitButton.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.bottomAnchor.constraint(equalTo: habitButton.topAnchor, constant: -295)
        ])
    }
}
