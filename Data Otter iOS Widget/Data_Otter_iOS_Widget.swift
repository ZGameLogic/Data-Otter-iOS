//
//  Data_Otter_iOS_Widget.swift
//  Data Otter iOS Widget
//
//  Created by Benjamin Shabowski on 5/14/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    let previewData: [MonitorStatus] = [
        MonitorStatus(id: 1, applicationId: 1, name: "Test Monitor 1", type: "API", url: "", regex: "", status: Status(dateRecorded: Date(), milliseconds: 1, status: true, attempts: 1, statusCode: 200)),
        MonitorStatus(id: 2, applicationId: 1, name: "Test Monitor 2", type: "API", url: "", regex: "", status: Status(dateRecorded: Date(), milliseconds: 1, status: true, attempts: 1, statusCode: 200)),
        MonitorStatus(id: 3, applicationId: 1, name: "Test Monitor 3", type: "WEB", url: "", regex: "", status: Status(dateRecorded: Date(), milliseconds: 1, status: true, attempts: 1, statusCode: 200)),
        MonitorStatus(id: 4, applicationId: 1, name: "Test Monitor 4", type: "API", url: "", regex: "", status: Status(dateRecorded: Date(), milliseconds: 1, status: true, attempts: 1, statusCode: 200))
    ]
    
    
    func placeholder(in context: Context) -> MonitorStatusEntry {
        MonitorStatusEntry(date: Date(), monitors: previewData)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MonitorStatusEntry {
        MonitorStatusEntry(date: Date(), monitors: previewData)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MonitorStatusEntry> {
        let newDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        var entries: [MonitorStatusEntry] = []
        let result = MonitorsService.getMonitorsWithStatusSyncronous()
        switch result {
        case .success(let monitors):
            entries.append(MonitorStatusEntry(date: newDate, monitors: monitors))
        case .failure(let error):
            print("Error: \(error)")
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct zgamemonitors: Widget {
    let kind: String = "zgamemonitors"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DataOtterGuageWidgetView(entry: entry)
        }
        .configurationDisplayName("Data Otter Guage")
        .description("Gets the status of the ZGameLogic monitors.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    zgamemonitors()
} timeline: {
    MonitorStatusEntry(date: Date(), monitors: [])
}
