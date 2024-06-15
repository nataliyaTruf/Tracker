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
    static func didOpenMain() {
        logEvent(event: "open", screen: "Main")
    }
    
    static func didCloseMain() {
        logEvent(event: "close", screen: "Main")
    }
    
    static func didClickAddTrack() {
        logEvent(event: "click", screen: "Main", item: "add_track")
    }
    
    static func didClickFilter() {
        logEvent(event: "click", screen: "Main", item: "filter")
    }
    
    static func didClickTrack() {
        logEvent(event: "click", screen: "Main", item: "track")
    }
    
    static func didClickEdit() {
        logEvent(event: "click", screen: "Main", item: "edit")
    }
    
    static func didClickDelete() {
        logEvent(event: "click", screen: "Main", item: "delete")
    }
}

