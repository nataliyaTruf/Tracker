//
//  UIColor+Extension.swift
//  Tracker
//
//  Created by Natasha Trufanova on 29/01/2024.
//

import UIKit

extension UIColor {
    static let colorMap: [String: UIColor] = [
        "colorSelection1": UIColor(resource: .colorSelection1),
        "colorSelection2": UIColor(resource: .colorSelection2),
        "colorSelection3": UIColor(resource: .colorSelection3),
        "colorSelection4": UIColor(resource: .colorSelection4),
        "colorSelection5": UIColor(resource: .colorSelection5),
        "colorSelection6": UIColor(resource: .colorSelection6),
        "colorSelection7": UIColor(resource: .colorSelection7),
        "colorSelection8": UIColor(resource: .colorSelection8),
        "colorSelection9": UIColor(resource: .colorSelection9),
        "colorSelection10": UIColor(resource: .colorSelection10),
        "colorSelection11": UIColor(resource: .colorSelection11),
        "colorSelection12": UIColor(resource: .colorSelection12),
        "colorSelection13": UIColor(resource: .colorSelection13),
        "colorSelection14": UIColor(resource: .colorSelection14),
        "colorSelection15": UIColor(resource: .colorSelection15),
        "colorSelection16": UIColor(resource: .colorSelection16),
        "colorSelection17": UIColor(resource: .colorSelection17),
        "colorSelection18": UIColor(resource: .colorSelection18)
    ]
    
    static func color(from string: String) -> UIColor? {
        return colorMap[string]
    }
   
    static func string(from color: UIColor) -> String? {
        return colorMap.first(where: { $1 == color })?.key
    }
}
