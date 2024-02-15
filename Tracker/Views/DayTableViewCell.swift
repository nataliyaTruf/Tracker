//
//  DayTableViewCell.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/02/2024.
//

import UIKit

final class DayTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    static let dayCellIdentifier = "DayCell"
    var onSwitchValueChanged: ((Bool) -> Void)?
    
    // MARK: - UI Components
    
    private lazy var daySwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .ypBlue
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.text = "Понедельник"
        label.textColor = .ypBlackDay
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ypBackgroundDay
        setupSwitch()
        setupSeparator()
        setupDayLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        onSwitchValueChanged?(sender.isOn)
    }
    
    // MARK: - Setup Methods
    
    private func setupSwitch() {
        contentView.addSubview(daySwitch)
        
        NSLayoutConstraint.activate([
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSeparator() {
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            separator.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        ])
    }
    
    private func setupDayLabel() {
        contentView.addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    // MARK: - Visibility Methods
    
    func hideSeparator() {
        separator.isHidden = true
    }
    
    func showSeparator() {
        separator.isHidden = false
    }
    
    // MARK: - Configuration
    
    func configure(with day: String, isOn: Bool) {
        dayLabel.text = day
        daySwitch.isOn = isOn
        daySwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
}
