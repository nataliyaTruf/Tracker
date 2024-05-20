//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Natasha Trufanova on 21/01/2024.
//

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    
    init(title: String, trackers: [Tracker] = []) {
        self.title = title
        self.trackers = trackers
    }
}
