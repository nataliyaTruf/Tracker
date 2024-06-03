//
//  EmptyStateType.swift
//  Tracker
//
//  Created by Natasha Trufanova on 24/05/2024.
//

import UIKit


enum EmptyStateType {
    case noCategories
    case noTrackers
    case noResults
    case noStats

    var image: UIImage? {
        switch self {
        case .noCategories:
            return UIImage(named: "error1")
        case .noTrackers:
            return UIImage(named: "error1")
        case .noResults:
            return UIImage(named: "error2")
        case .noStats:
            return UIImage(named: "error3")
        }
    }

    var text: String {
        switch self {
        case .noCategories:
            return L10n.noCategories
        case .noTrackers:
            return L10n.noTrackers
        case .noResults:
            return L10n.noResults
        case .noStats:
            return L10n.noStats
        }
    }
}

