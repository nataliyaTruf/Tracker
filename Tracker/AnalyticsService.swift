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
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "API_KEY") else {
            return
        }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    static func logEvent(event: String, screen: String, item: String? = nil) {
        var eventParameters: [String: Any] = [
            "event": event,
            "screen": screen
        ]
        if let item = item {
            eventParameters["item"] = item
        }
        print("Logging event: \(eventParameters)")
        YMMYandexMetrica.reportEvent("ui_event", parameters: eventParameters, onFailure: { error in
            print("Error: \(error.localizedDescription)")
        })
    }
}
