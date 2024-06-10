//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 14/05/2024.
//

import UIKit

final class AddCategoryViewController: UIViewController {
    // MARK: - Properties
    
    var onCategoryAdded: ((String) -> Void)?
    private var viewModel = AddCategoryViewModel()
    
    // MARK: - UI Components
    
    private lazy var titleLabel = CustomTitleLabel(text: L10n.addCategoryTitle)
    
    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: L10n.done)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: L10n.enterCategoryName)
        textField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        return textField
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setuptitleLabel()
        setupDoneButton()
        setupNameTextField()
        bindViewModel()
        validateInitialButtonState()
    }
    
    // MARK: - Binding ViewModel
    
    private func bindViewModel() {
        viewModel.onCategoryAdded = { [weak self] categoryName in
            self?.onCategoryAdded?(categoryName)
            self?.dismiss(animated: true, completion: nil)
        }
        
        viewModel.onDoneButtonStateUpdated = { [weak self] isEnabled in
            self?.doneButton.isEnabled = isEnabled
            self?.doneButton.backgroundColor = isEnabled ? .ypBlackDay : .ypGray
        }
        
        viewModel.onInvalidCategoryName = { [weak self] isInvalid in
                    self?.nameTextField.textColor = isInvalid ? .red : .black
                    if isInvalid {
                        self?.nameTextField.text = ""
                        self?.nameTextField.placeholder = "Название недопустимо"
                    } else {
                        self?.nameTextField.placeholder = L10n.enterCategoryName
                    }
                }
    }
    
    // MARK: - Setup Methods
    
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
    
    // MARK: - Private Methods
    
    private func validateInitialButtonState() {
        viewModel.validateCategoryName(nameTextField.text)
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        if let categoryName = nameTextField.text, !categoryName.isEmpty {
            viewModel.addCategory(name: categoryName)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.validateCategoryName(textField.text)
    }
}

// MARK: - UITextFieldDelegate

extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
