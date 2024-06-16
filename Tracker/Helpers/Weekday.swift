//
//  Weekday.swift
//  Tracker
//
//  Created by Natasha Trufanova on 25/05/2024.
//

import Foundation


enum Weekday: Int, Codable, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var localizedString: String {
        switch self {
        case .monday: return L10n.weekdayMonday
        case .tuesday: return L10n.weekdayTuesday
        case .wednesday: return L10n.weekdayWednesday
        case .thursday: return L10n.weekdayThursday
        case .friday: return L10n.weekdayFriday
        case .saturday: return L10n.weekdaySaturday
        case .sunday: return L10n.weekdaySunday
        }
    }
    
    var localizedStringShort: String {
        switch self {
        case .monday: return L10n.weekdayMondayShort
        case .tuesday: return L10n.weekdayTuesdayShort
        case .wednesday: return L10n.weekdayWednesdayShort
        case .thursday: return L10n.weekdayThursdayShort
        case .friday: return L10n.weekdayFridayShort
        case .saturday: return L10n.weekdaySaturdayShort
        case .sunday: return L10n.weekdaySundayShort
        }
    }
}
