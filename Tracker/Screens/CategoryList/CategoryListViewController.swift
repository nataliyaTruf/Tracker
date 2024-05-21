//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 30/04/2024.
//

import UIKit


final class CategoryListViewController: UIViewController {
    // MARK: - Properties
    
    private var viewModel = CategoryListViewModel()
    var onSelectCategory: ((String) -> Void)?
    
    // MARK: - UI Components
    
    private var tableView: UITableView!
    private lazy var titleLabel = CustomTitleLabel(text: "Категория")
    
    private lazy var addCategoryButton: CustomButton = {
        let button = CustomButton(title: "Добавить категорию")
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        
        setupTitleLabel()
        setupAddCategoryButton()
        setupTableView()
        
        bindViewModel()
    }
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdated = { [weak self] categories in
            self?.tableView.reloadData()
        }
        
        viewModel.onCategorySelected = { [weak self] categoryName in
            guard let self = self else { return }
            self.onSelectCategory?(categoryName)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryButtonTapped() {
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.onCategoryAdded = { [weak self] newCategoryName in
            self?.viewModel.addCategory(name: newCategoryName)
        }
        addCategoryVC.modalPresentationStyle = .pageSheet
        present(addCategoryVC, animated: true)
    }
    
    // MARK: - Setup Methods
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.configureStandardStyle()
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 87),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -39)
        ])
    }
    
    private func setupAddCategoryButton() {
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConfigurableTableViewCell.identifier, for: indexPath) as? ConfigurableTableViewCell else {
            assertionFailure("Unable to dequeue DayTableViewCell")
            return UITableViewCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        cell.configure(with: category.title, accessoryType: .none)
        cell.accessoryType = (indexPath == viewModel.selectedIndex) ? .checkmark : .none
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if isLastCell {
            cell.hideSeparator()
        } else {
            cell.showSeparator()
        }
        
        cell.layer.cornerRadius = isLastCell ? 16 : 0
        cell.layer.maskedCorners = isLastCell ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] : []
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        tableView.reloadData()
    }
}
