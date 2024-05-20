//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 30/04/2024.
//

import UIKit

final class CategoryListViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var tableView: UITableView!
    var selectedCategory: TrackerCategory?
    var selectedIndex: IndexPath?
    var onSelectCategory: ((String) -> Void)?
    
    private let categoryStore = CoreDataStack.shared.trackerCategoryStore
    
    private lazy var titleLabel = CustomTitleLabel(text: "Категория")
    
    private lazy var addCategoryButton: CustomButton = {
        let button = CustomButton(title: "Добавить категорию")
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setuptitleLabel()
        setupAddCategoryButton()
        setupTableView()
        loadCategories()
    }
    
    @objc private func addCategoryButtonTapped() {
        let addCategoryVC = AddCategoryViewController()
        addCategoryVC.onCategoryAdded = { [weak self] newCategoryName in
            guard let self = self else { return }
            self.categoryStore.createCategory(title: newCategoryName)
            self.loadCategories()
        }
        addCategoryVC.modalPresentationStyle = .pageSheet
        present(addCategoryVC, animated: true)
    }
    
    private func setuptitleLabel() {
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
    
    private func loadCategories() {
        categories = categoryStore.getAllCategoriesWithTrackers()
        tableView.reloadData()
    }
}

extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConfigurableTableViewCell.identifier, for: indexPath) as? ConfigurableTableViewCell else {
            assertionFailure("Unable to dequeue DayTableViewCell")
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        cell.configure(with: category.title, accessoryType: .none)
        cell.accessoryType = (indexPath == selectedIndex) ? .checkmark : .none
        
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
        selectedIndex = indexPath
        selectedCategory = categories[indexPath.row]
        onSelectCategory?(selectedCategory?.title ?? "По умолчанию")
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: nil)
            }
    }
}
