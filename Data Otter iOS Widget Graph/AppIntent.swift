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
    
    @Parameter(title: "Category", requestValueDialog: "Select a category")
    var category: WidgetCategory?

    init() {
        self.category = .monitors
    }
}

enum WidgetCategory: String, AppEnum {
    case applications = "Applications"
    case monitors = "Monitors"
    case agents = "Agents"

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Widget Category")

    static var caseDisplayRepresentations: [WidgetCategory: DisplayRepresentation] = [
        .applications: DisplayRepresentation(title: "Applications"),
        .monitors: DisplayRepresentation(title: "Monitors"),
        .agents: DisplayRepresentation(title: "Agents")
    ]
}
