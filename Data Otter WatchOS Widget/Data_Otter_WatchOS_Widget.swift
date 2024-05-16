//
//  Data_Otter_WatchOS_Widget.swift
//  Data Otter WatchOS Widget
//
//  Created by Benjamin Shabowski on 5/15/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    let previewData: [MonitorStatus] = [
        MonitorStatus(id: 1, name: "Test Monitor 1", type: "API", url: "", regex: "", status: Status(dateRecorded: Date(), milliseconds: 1, status: true, attempts: 1, statusCode: 200)),
        MonitorStatus(id: 2, name: "Test Monitor 2", type: "API", url: "", regex: "", status: Status(dateRecorded: Date(), milliseconds: 1, status: true, attempts: 1, statusCode: 200)),
        MonitorStatus(id: 3, name: "Test Monitor 3", type: "WEB", url: "", regex: "", status: Status(dateRecorded: Date(), milliseconds: 1, status: true, attempts: 1, statusCode: 200)),
        MonitorStatus(id: 4, name: "Test Monitor 4", type: "API", url: "", regex: "", status: Status(dateRecorded: Date(), milliseconds: 1, status: true, attempts: 1, statusCode: 200))
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

    func recommendations() -> [AppIntentRecommendation<ConfigurationAppIntent>] {
        // Create an array with all the preconfigured widgets to show.
        [AppIntentRecommendation(intent: ConfigurationAppIntent(), description: "Example Widget")]
    }
}

struct Data_Otter_WatchOS_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Gauge(value: Double(entry.up), in: 0...Double(entry.total)){}
        currentValueLabel: {
            Text(entry.up, format: .number).foregroundColor(entry.down == 0 ? .green : .red)
        } minimumValueLabel: {
            Text("0").foregroundColor(.red)
        } maximumValueLabel: {
            Text(entry.total, format: .number).foregroundColor(.green)
        }
        .gaugeStyle(.accessoryCircular)
        .tint(entry.down == 0 ? .green : .red)
    }
}

@main
struct Data_Otter_WatchOS_Widget: Widget {
    let kind: String = "Data_Otter_WatchOS_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Data_Otter_WatchOS_WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Data Otter")
        .description("Gets the status of the ZGameLogic monitors.")
        .supportedFamilies([.accessoryCircular])
    }
}

#Preview(as: .accessoryRectangular) {
    Data_Otter_WatchOS_Widget()
} timeline: {
    MonitorStatusEntry(date: Date(), monitors: [])
}
