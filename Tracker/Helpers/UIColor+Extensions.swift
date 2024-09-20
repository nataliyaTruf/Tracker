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
    
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let mask: UInt64 = 0x000000FF
        let r = CGFloat((rgb >> 16) & mask) / 255.0
        let g = CGFloat((rgb >> 8) & mask) / 255.0
        let b = CGFloat(rgb & mask) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
