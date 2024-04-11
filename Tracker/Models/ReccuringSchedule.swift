//
//  ReccuringSchedule.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/01/2024.
//

import Foundation

//struct ReccuringSchedule {
//    var recurringDays: [Weekday] = []
//    
//    var scheduleText: String {
//        let daysText = recurringDays.map { $0.localizedStringShort }
//        return daysText.joined(separator: ", ")
//    }
//    
//    func isReccuringOn(_ day: Weekday) -> Bool {
//        return recurringDays.contains(day)
//    }
//}

class ReccuringSchedule: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    var recurringDays: [Int]
    var scheduleText: String {
           let daysText = recurringDays.map { Weekday(rawValue: $0)?.localizedStringShort ?? "" }
           return daysText.joined(separator: ", ")
       }
    
    init(recurringDays: [Int] = []) {
        self.recurringDays = recurringDays
    }
    
    required init?(coder: NSCoder) {
        self.recurringDays = coder.decodeObject(forKey: "recurringDays") as? [Int] ?? []
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(recurringDays, forKey: "recurringDays")
    }
   
    func addDay(_ day: Weekday) {
           recurringDays.append(day.rawValue)
       }

       func removeDay(_ day: Weekday) {
           recurringDays.removeAll { $0 == day.rawValue }
       }

       func isReccuringOn(_ day: Weekday) -> Bool {
           return recurringDays.contains(day.rawValue)
       }
}

enum Weekday: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
}

extension Weekday {
    var localizedString: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
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
