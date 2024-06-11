//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Natasha Trufanova on 11/06/2024.
//

import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "ae22eab9-2e67-46f1-ae91-f96361cc68cf") else {
            return
        }
        
        YMMYandexMetrica.activate(with: configuration)
    }
}
