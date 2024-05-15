//
//  AppIntent.swift
//  Data Otter iOS Widget Graph
//
//  Created by Benjamin Shabowski on 5/15/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Data Otter Graph"
    static var description = IntentDescription("A graph widget to show up up/down status history.")
}
