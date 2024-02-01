//
//  TrackersCell.swift
//  Tracker
//
//  Created by Natasha Trufanova on 27/01/2024.
//

import UIKit

final class TrackersCell: UICollectionViewCell {
    static let cellIdetnifier = "TrackersCell"
    var onToggleCompleted: (() -> Void)?
    
    var isCompleted: Bool = false {
        didSet {
            print("isCompleted изменился на \(isCompleted) 🦖")
            let buttonImage = isCompleted ? UIImage(named: "done") : plusImage
            markAsCompleteButton.setImage(buttonImage, for: .normal)
            markAsCompleteButton.alpha = isCompleted ? 0.3 : 1
        }
    }
    
    // MARK: UI Elements
    
    private lazy var topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .colorSelection18)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "😪"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor(resource: .ypWhiteDay)
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.text = "Поливать растения"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bottomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var plusImage: UIImage? = {
        return UIImage(systemName: "plus")?
            .withTintColor(UIColor(resource: .ypWhiteDay), renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
    }()
    
    private lazy var markAsCompleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(resource: .colorSelection18)
        button.setImage(plusImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        markAsCompleteButton.addTarget(
            self,
            action: #selector(markAsCompleteButtonTapped),
            for: .touchUpInside
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topBackgroundView.layer.cornerRadius = 16
        topBackgroundView.layer.masksToBounds = true
        
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        
        markAsCompleteButton.layer.cornerRadius = 17
        markAsCompleteButton.clipsToBounds = true
    }
    
    @objc private func markAsCompleteButtonTapped() {
        onToggleCompleted?()
        print("КНОПКА БЫЛА НАЖАТА 🎾")
    }
    
    private func setupViews() {
        contentView.addSubview(topBackgroundView)
        contentView.addSubview(bottomBackgroundView)
        contentView.addSubview(emojiBackgroundView)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(daysCounterLabel)
        contentView.addSubview(markAsCompleteButton)
        
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            topBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topBackgroundView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor, constant: -12),
            nameLabel.heightAnchor.constraint(equalToConstant: 34),
            nameLabel.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor, constant: -12),
            
            bottomBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomBackgroundView.topAnchor.constraint(equalTo: topBackgroundView.bottomAnchor),
            bottomBackgroundView.heightAnchor.constraint(equalToConstant: 58),
            
            markAsCompleteButton.trailingAnchor.constraint(equalTo: bottomBackgroundView.trailingAnchor, constant: -12),
            markAsCompleteButton.bottomAnchor.constraint(equalTo: bottomBackgroundView.bottomAnchor, constant: -16),
            markAsCompleteButton.widthAnchor.constraint(equalToConstant: 34),
            markAsCompleteButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCounterLabel.centerYAnchor.constraint(equalTo: markAsCompleteButton.centerYAnchor),
            daysCounterLabel.leadingAnchor.constraint(equalTo: bottomBackgroundView.leadingAnchor, constant: 12),
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int) {
        emojiLabel.text = tracker.emodji
        nameLabel.text = tracker.name
        topBackgroundView.backgroundColor =  UIColor.color(from: tracker.color) ?? .blue
        markAsCompleteButton.backgroundColor = topBackgroundView.backgroundColor
        daysCounterLabel.text = "\(completedDays) дней"
    }
}
