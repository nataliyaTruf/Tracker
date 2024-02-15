//
//  TrackersCollectionHeaderView.swift
//  Tracker
//
//  Created by Natasha Trufanova on 28/01/2024.
//

import UIKit


final class ReusableHeader: UICollectionReusableView {    
    // MARK: - Properties
    
    static let identifier = "TrackersHeader"
    
    let titleLabel = UILabel()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.text = "Домашний уют"
        titleLabel.font = UIFont(name: "YSDisplay-Bold", size: 19)
        titleLabel.textColor = .ypBlackDay
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
        func configure(with title: String) {
            titleLabel.text = title
        }
}
