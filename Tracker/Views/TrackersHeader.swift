//
//  TrackersCollectionHeaderView.swift
//  Tracker
//
//  Created by Natasha Trufanova on 28/01/2024.
//

import UIKit


final class TrackersHeader: UICollectionReusableView {
    static let headerIdentifier = "TrackersHeader"
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(titleLabel)
        titleLabel.text = "Домашний уют"
        titleLabel.font = UIFont(name: "YSDisplay-Bold", size: 19)
        titleLabel.textColor = UIColor(resource: .ypBlackDay)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
