//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Natasha Trufanova on 13/06/2024.
//

import Foundation
import Combine

final class StatisticsViewModel {
    // Published properties
    
    @Published var completedTrackersCount: Int = 0
    @Published var viewState: ViewState = .empty
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        loadStatistics()
        
        CoreDataStack.shared.trackerRecordStore.completedTrackersCountSubject
            .sink { [weak self] count in
                print("Received updated completed trackers count: \(count)")
                self?.completedTrackersCount = count
                self?.updateViewState()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - PrivateMethods
    
    private func loadStatistics() {
        completedTrackersCount = CoreDataStack.shared.trackerRecordStore.loadCompletedTrackersCount()
        updateViewState()
    }
    
    private func updateViewState() {
        viewState = completedTrackersCount == 0 ? .empty : .populated
    }
}

