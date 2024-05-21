//
//  CustomTextField.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/05/2024.
//

import UIKit

final class CustomTextField: UITextField {
    init(placeholder: String) {
        super.init(frame: .zero)
        setupTextField(placeholder: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField(placeholder: String) {
        self.placeholder = placeholder
        self.textColor = .ypBlackDay
        self.textAlignment = .left
        self.borderStyle = .none
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        self.backgroundColor = .ypBackgroundDay
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
