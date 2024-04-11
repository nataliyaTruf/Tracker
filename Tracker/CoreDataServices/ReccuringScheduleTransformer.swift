//
//  ReccuringScheduleTransformer.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/04/2024.
//

import Foundation

@objc(ReccuringScheduleTransformer)
final class ReccuringScheduleTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
            guard let days = value as? [Int] else { return nil }
            return try? JSONEncoder().encode(days)
        }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
            guard let data = value as? NSData else { return nil }
            return try? JSONDecoder().decode([Int].self, from: data as Data)
        }
}

extension ReccuringScheduleTransformer {
    static func register() {
        ValueTransformer.setValueTransformer(ReccuringScheduleTransformer(), forName: NSValueTransformerName(rawValue: String(describing: ReccuringScheduleTransformer.self)))
    }
}
