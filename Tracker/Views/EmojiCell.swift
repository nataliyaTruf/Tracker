//
//  EmojiCell.swift
//  Tracker
//
//  Created by Natasha Trufanova on 14/02/2024.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
    // MARK: - Properties
    
    static let idetnifier = "EmojiCell"
    
    // MARK: - UI Components
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "YSDisplay-Bold", size: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        contentView.addSubview(emojiLabel)
        
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        contentView.backgroundColor = isSelected ? UIColor.ypLightGray : UIColor.clear
    }
}

