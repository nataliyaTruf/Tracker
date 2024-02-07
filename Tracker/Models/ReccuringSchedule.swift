//
//  ReccuringSchedule.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/01/2024.
//

import Foundation

struct ReccuringSchedule {
    var mondays: Bool
    var tuesdays: Bool
    var wednesdays: Bool
    var thursdays: Bool
    var fridays: Bool
    var saturdays: Bool
    var sundays: Bool
    
    func isReccuringOn(_ day: Weekday) -> Bool {
        switch day {
        case .monday:
            return mondays
        case .tuesday:
            return tuesdays
        case .wednesday:
            return wednesdays
        case .thursday:
            return thursdays
        case .friday:
            return fridays
        case .saturday:
            return saturdays
        case .sunday:
            return sundays
        }
    }
}

enum Weekday {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

extension Date {
    func toWeekday() -> Weekday {
        let calendar = Calendar.current
        let dayNumber = calendar.component(.weekday, from: self)
        switch dayNumber {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            fatalError("Invalid day number")
        }
    }
}
