//
//  Fonts.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/05/2024.
//

import UIKit


struct Fonts {
    static func medium(size: CGFloat) -> UIFont {
        return UIFont(name: "YSDisplay-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func bold(size: CGFloat) -> UIFont {
        return UIFont(name: "YSDisplay-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
}
