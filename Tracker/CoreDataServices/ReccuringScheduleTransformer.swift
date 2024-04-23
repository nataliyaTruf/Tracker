//
//  ReccuringScheduleTransformer.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation

@objc(ReccuringScheduleTransformer)
final class ReccuringScheduleTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
            return NSData.self
        }

        override class func allowsReverseTransformation() -> Bool {
            return true
        }

        override func transformedValue(_ value: Any?) -> Any? {
            guard let data = value as? Data else {
                print("Ошибка: ожидаемый тип Data, получен \(type(of: value))")
                return nil
            }
            return data
        }

        override func reverseTransformedValue(_ value: Any?) -> Any? {
            guard let data = value as? Data else {
                return nil
            }
            return data
        }

    static func register() {
        let transformer = ReccuringScheduleTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: String(describing: ReccuringScheduleTransformer.self)))
    }
}
