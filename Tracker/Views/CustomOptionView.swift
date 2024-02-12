//
//  CustomOptionView.swift
//  Tracker
//
//  Created by Natasha Trufanova on 09/02/2024.
//

import UIKit


final class CustomOptionView: UIView {
    var onTap: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = .ypBlackDay
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var arrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chevron")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var additionalTextLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .ypGray
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .ypBackgroundDay
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
      @objc private func viewTaped() {
          onTap?()
      }
      
    private func setupLayout() {
        addSubview(stackView)
        addSubview(arrowIcon)
        stackView.addArrangedSubview(titleLabel)
        if additionalTextLabel.text != nil {
            stackView.addArrangedSubview(additionalTextLabel)
        }
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTaped))
        addGestureRecognizer(tapGesture)
    }

    func configure(with title: String, additionalText: String?) {
        titleLabel.text = title
        additionalTextLabel.text = additionalText
    }
}
