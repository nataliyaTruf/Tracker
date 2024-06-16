//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Natasha Trufanova on 15/01/2024.
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: StatisticsViewModel = StatisticsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.statisticsTitle
        label.font = Fonts.bold(size: 34)
        label.textColor = .ypBlackDay
        label.contentMode = .scaleAspectFit
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statisticItemView: StatisticItemView = {
        let view = StatisticItemView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(value: 0, description: "Трекеров завершено")
        return view
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        setupTitleLabel()
        setupEmptyStateStats()
        setupPopulatedState()
        bindViewModel()
    }
    
    // MARK: - Binding ViewModel
    
    private func bindViewModel() {
        viewModel.$completedTrackersCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.statisticItemView.configure(value: count, description: "Трекеров завершено")
            }
            .store(in: &cancellables)
        
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateViewState(state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Setup Methods
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupEmptyStateStats() {
        view.addSubview(emptyStateView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 49),
        ])
        
        emptyStateView.configure(with: .noStats, labelHeight: 18)
    }
    
    private func setupPopulatedState() {
        view.addSubview(statisticItemView)
        
        NSLayoutConstraint.activate([
            statisticItemView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            statisticItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticItemView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    private func updateViewState(_ state: ViewState) {
        switch state {
        case .empty:
            emptyStateView.isHidden = false
            statisticItemView.isHidden = true
        case .populated:
            emptyStateView.isHidden = true
            statisticItemView.isHidden = false
        }
    }
}
