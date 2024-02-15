//
//  ColorCell.swift
//  Tracker
//
//  Created by Natasha Trufanova on 14/02/2024.
//

import UIKit

class ColorCell: UICollectionViewCell {
    // MARK: - Properties
    
    static let idetnifier = "ColorCell"
    
    // MARK: - UI Components
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        contentView.addSubview(colorView)
        
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -3),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 3),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3)
        ])
    }
    
    // MARK: - Configuration

    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
    }
    
}
