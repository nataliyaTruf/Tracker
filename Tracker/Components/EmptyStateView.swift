//
//  EmptyStateView.swift
//  Tracker
//
//  Created by Natasha Trufanova on 24/05/2024.
//

import UIKit


final class EmptyStateView: UIView {
    // MARK: - Properties
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium(size: 12)
        label.textAlignment = .center
        label.contentMode = .scaleAspectFill
        label.textColor = .ypBlackDay
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            setupView()
        }
    }
    
    // MARK: - Configuration
    
    func configure(with type: EmptyStateType, labelHeight: CGFloat) {
        imageView.image = type.image
        label.text = type.text
        
        label.heightAnchor.constraint(equalToConstant: labelHeight).isActive = true
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        addSubview(stackView)
        guard let superview = superview else { return }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
