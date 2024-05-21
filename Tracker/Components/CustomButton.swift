//
//  CustomButton.swift
//  Tracker
//
//  Created by Natasha Trufanova on 29/04/2024.
//

import UIKit

final class CustomButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = Fonts.medium(size: 16)
        setTitleColor(.ypWhiteDay, for: .normal)
        backgroundColor = .ypBlackDay
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            setupDefaultConstraints()
        }
    }
    
    private func setupDefaultConstraints() {
        guard let superview = superview else { return }
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -20),
            heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func addAction(target: Any?, action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
}
