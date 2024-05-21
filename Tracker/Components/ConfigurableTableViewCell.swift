//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Natasha Trufanova on 30/04/2024.
//

import UIKit

enum CellAccessoryType {
    case none
    case arrow
    case checkmark
    case switchControl(isOn: Bool)
}

// MARK: - Main Class

final class ConfigurableTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    static let identifier = "ConfigurableCell"
    var onSwitchValueChanged: ((Bool) -> Void)?
    var onCellTapped: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlackDay
        label.font = Fonts.medium(size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var additionalTextLabel: UILabel = {
        let label = UILabel()
        label.text = "расписание"
        label.textColor = .ypGray
        label.font = Fonts.medium(size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var arrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chevron")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var accessorySwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .ypBlue
        switchControl.isHidden = true
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    private lazy var checkmarkIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "selectmark")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .ypBackgroundDay
        setupLayout()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func switchValueChanged(_ sender: UISwitch) {
        onSwitchValueChanged?(sender.isOn)
    }
    
    
    @objc private func cellTapped() {
        onCellTapped?()
    }
  
    private func setupLayout() {
        contentView.addSubview(stackView)
        contentView.addSubview(separator)
        contentView.addSubview(accessorySwitch)
        
        addSubview(stackView)
        addSubview(arrowIcon)
        stackView.addArrangedSubview(titleLabel)
        if additionalTextLabel.text != nil {
            stackView.addArrangedSubview(additionalTextLabel)
        }
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            separator.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            
            accessorySwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessorySwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            arrowIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    func hideSeparator() {
        separator.isHidden = true
    }
    
    func showSeparator() {
        separator.isHidden = false
    }
    
    func configure(with text: String, additionalText: String? = nil, accessoryType: CellAccessoryType) {
        titleLabel.text = text
        additionalTextLabel.text = additionalText
        additionalTextLabel.isHidden = additionalText == nil
        
        arrowIcon.isHidden = true
        accessorySwitch.isHidden = true
        checkmarkIcon.isHidden = true
        
        switch accessoryType {
        case .none:
            selectionStyle = .none
        case .arrow:
            arrowIcon.isHidden = false
            selectionStyle = .none
        case .checkmark:
            checkmarkIcon.isHidden = false
            selectionStyle = .blue
        case .switchControl(let isOn):
                    accessorySwitch.isHidden = false
                    accessorySwitch.isOn = isOn
            accessorySwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        }
    }
}
