//
//  Array+Extensions.swift
//  Tracker
//
//  Created by Natasha Trufanova on 10/06/2024.
//

import Foundation


extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
