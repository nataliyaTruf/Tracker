//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 15/01/2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    private let emptyStateImageView = {
        let image = UIImageView(image: UIImage(named: "error3"))
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = UIFont(name: "YSDisplay-Bold", size: 34)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setupEmptyStateStats()
    }
    
    private func setupEmptyStateStats() {
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: +8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
}
