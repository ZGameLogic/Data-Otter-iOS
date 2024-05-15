//
//  AppIntent.swift
//  Data Otter iOS Widget
//
//  Created by Benjamin Shabowski on 5/14/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Data Otter Guage"
    static var description = IntentDescription("A guage showing up/dwon monitors.")
}
