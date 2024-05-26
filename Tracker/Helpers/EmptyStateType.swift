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
            return "Привычки и события можно\nобъединить по смыслу"
        case .noTrackers:
            return "Что будем отслеживать?"
        case .noResults:
            return "Ничего не найдено"
        case .noStats:
            return "Анализировать пока нечего"
        }
    }
}

