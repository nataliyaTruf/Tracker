//
//  CreateTrackerController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 09/02/2024.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .ypWhiteDay
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        label.textColor = UIColor.ypBlackDay
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField = {
        let textField = UITextField()
        textField.placeholder = "Введите назывние трекера"
        textField.textColor = .ypBlackDay
        textField.textAlignment = .left
        textField.borderStyle = .none
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackgroundDay
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var categoryView: CustomOptionView = {
        let view = CustomOptionView()
        view.configure(with: "Категория", additionalText: nil)
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var scheduleView: CustomOptionView = {
        let view = CustomOptionView()
        view.configure(with: "Расписание", additionalText: nil)
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return view
    }()
    
    private lazy var buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.tintColor = UIColor.ypRed
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.backgroundColor = UIColor.ypGray
        button.layer.borderColor = UIColor.ypGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.tintColor = UIColor.ypWhiteDay
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(categoryView)
        let divider = createDivider()
        stackView.addArrangedSubview(divider)
        stackView.addArrangedSubview(scheduleView)
        stackView.addArrangedSubview(buttonsView)
        
        setupTitleView()
        setupButtonsView()
        setupSpacing()
    }
    
    private func setupSpacing() {
        stackView.setCustomSpacing(24, after: titleView)
        stackView.setCustomSpacing(24, after: nameTextField)
        stackView.setCustomSpacing(508, after: scheduleView)
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            buttonsView.heightAnchor.constraint(equalToConstant: 60),
            categoryView.heightAnchor.constraint(equalToConstant: 75),
            scheduleView.heightAnchor.constraint(equalToConstant: 75),
            titleView.heightAnchor.constraint(equalToConstant: 70),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
        ])
    }
}

extension CreateTrackerViewController {
   
    private func setupTitleView() {
        titleView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -14),
            titleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setupButtonsView() {
        buttonsView.addSubview(cancelButton)
        buttonsView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 4),
            cancelButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -4),
            createButton.topAnchor.constraint(equalTo: buttonsView.topAnchor),
            createButton.bottomAnchor.constraint(equalTo: buttonsView.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    private func createDivider() -> UIView {
        let dividerContainer = UIView()
        dividerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let divider = UIView()
        divider.backgroundColor = UIColor.ypGray
        divider.translatesAutoresizingMaskIntoConstraints = false
        dividerContainer.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            divider.centerXAnchor.constraint(equalTo: dividerContainer.centerXAnchor),
            divider.centerYAnchor.constraint(equalTo: dividerContainer.centerYAnchor),
            divider.widthAnchor.constraint(equalTo: dividerContainer.widthAnchor, multiplier: 0.9)
        ])
        NSLayoutConstraint.activate([
            dividerContainer.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        return dividerContainer
    }
}
