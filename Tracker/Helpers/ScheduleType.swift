//
//  ScheduleType.swift
//  Tracker
//
//  Created by Natasha Trufanova on 25/05/2024.
//

import Foundation


enum ScheduleType {
    case everyday
    case weekdays
    case weekend
    case custom(days: [Int])
    
    init(from days: [Int]) {
        let daysSet = Set(days)
        if daysSet == Set(Weekday.allCases.map { $0.rawValue }) {
            self = .everyday
        } else if daysSet == Set([Weekday.monday.rawValue, Weekday.tuesday.rawValue, Weekday.wednesday.rawValue, Weekday.thursday.rawValue, Weekday.friday.rawValue]) {
            self = .weekdays
        } else if daysSet.isSubset(of: [Weekday.saturday.rawValue, Weekday.sunday.rawValue]) {
            self = .weekend
        } else {
            self = .custom(days: days)
        }
    }
    
    var description: String {
        switch self {
        case .everyday:
            return L10n.everyday
        case .weekdays:
            return L10n.weekdays
        case .weekend:
            return L10n.weekend
        case .custom(let days):
            return days.compactMap { Weekday(rawValue: $0)?.localizedStringShort }.joined(separator: ", ")
        }
    }
}
