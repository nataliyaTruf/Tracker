//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 14/05/2024.
//

import UIKit

final class AddCategoryViewController: UIViewController {
    var onCategoryAdded: ((String) -> Void)?
    private lazy var titleLabel = CustomTitleLabel(text: "Категория")
    private let categoryStore = CoreDataStack.shared.trackerCategoryStore
    
    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: "Готово")
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.textColor = .ypBlackDay
        textField.textAlignment = .left
        textField.borderStyle = .none
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypBackgroundDay
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setuptitleLabel()
        setupDoneButton()
        setupNameTextField()
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        if let categoryName = nameTextField.text, !categoryName.isEmpty {
            categoryStore.createCategory(title: categoryName)
            onCategoryAdded?(categoryName)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateDoneButtonState()
    }
    
    private func setuptitleLabel() {
        view.addSubview(titleLabel)
    }
    
    private func setupNameTextField() {
        view.addSubview(nameTextField)
        nameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupDoneButton() {
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func updateDoneButtonState() {
            let isNameEntered = !(nameTextField.text?.isEmpty ?? true)
  
            doneButton.isEnabled = isNameEntered
            doneButton.backgroundColor = isNameEntered ? .ypBlackDay : .ypGray
        
    }
}

extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
