//
//  ReccuringSchedule.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/01/2024.
//


import Foundation

struct ReccuringSchedule: Codable {
    var recurringDays: [Int]

    var scheduleText: String {
        let daysText = recurringDays.compactMap { Weekday(rawValue: $0)?.localizedStringShort }
        return daysText.joined(separator: ", ")
    }

    func isReccuringOn(_ day: Weekday) -> Bool {
        return recurringDays.contains(day.rawValue)
    }

    mutating func addDay(_ day: Weekday) {
        recurringDays.append(day.rawValue)
    }

    mutating func removeDay(_ day: Weekday) {
        recurringDays.removeAll { $0 == day.rawValue }
    }
}

enum Weekday: Int, Codable, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var localizedStringShort: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
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
