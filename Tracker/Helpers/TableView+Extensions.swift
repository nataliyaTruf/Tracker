//
//  TableView+Extensions.swift
//  Tracker
//
//  Created by Natasha Trufanova on 30/04/2024.
//

import UIKit

extension UITableView {
    func configureStandardStyle() {
        self.separatorStyle = .none
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        self.backgroundColor = .ypWhiteDay
        self.isScrollEnabled = false
        self.rowHeight = 75
        self.register(ConfigurableTableViewCell.self, forCellReuseIdentifier: ConfigurableTableViewCell.identifier)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            setupDefaultHorizontalConstraints()
        }
    }
    
    private func setupDefaultHorizontalConstraints() {
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16)
        ])
    }
}
