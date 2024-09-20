//
//  StatisticItemView.swift
//  Tracker
//
//  Created by Natasha Trufanova on 11/06/2024.
//

import UIKit

final class StatisticItemView: UIView {
    
    // MARK: - UI Components
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold(size: 34)
        label.textColor = .ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium(size: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientBorderLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(hex: "#007BFA").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#FD4C49").cgColor
        ]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        return gradient
    }()
    
    private let borderShapeLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        return shape
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        layer.addSublayer(gradientBorderLayer)
        gradientBorderLayer.mask = borderShapeLayer
        
        addSubview(valueLabel)
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            descriptionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientBorderLayer.frame = bounds
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(
                dx: borderShapeLayer.lineWidth / 2,
                dy: borderShapeLayer.lineWidth / 2
            ),
            cornerRadius: 16
        )
        borderShapeLayer.path = path.cgPath
    }
    
    // MARK: - Configuration
    
    func configure(value: Int, description: String) {
        valueLabel.text = "\(value)"
        descriptionLabel.text = description
    }
}
