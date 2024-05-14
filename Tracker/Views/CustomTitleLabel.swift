//
//  CustomTitleLabel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 29/04/2024.
//

import UIKit

final class CustomTitleLabel: UILabel {
    
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        font = UIFont(name: "YSDisplay-Medium", size: 16)
        textColor = .ypBlackDay
        textAlignment = .center
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
            topAnchor.constraint(equalTo: superview.topAnchor, constant: 27),
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}
