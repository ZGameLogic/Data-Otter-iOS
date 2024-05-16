//
//  AppIntent.swift
//  Data Otter WatchOS Widget
//
//  Created by Benjamin Shabowski on 5/15/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Data Otter Guage"
    static var description = IntentDescription("Guage for monitors")
}
