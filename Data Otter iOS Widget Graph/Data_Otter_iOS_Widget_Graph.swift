//
//  Data_Otter_iOS_Widget_Graph.swift
//  Data Otter iOS Widget Graph
//
//  Created by Benjamin Shabowski on 5/15/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    let previewData: [Monitor]
    let startDate: Date
    let endDate: Date
    let previewHistoryData: [String: [Status]]
    
    init() {
        previewData = [
            Monitor(id: 1, applicationId: 1, name: "Test Monitor 1", type: "API", url: "", regex: "", status: nil),
            Monitor(id: 2, applicationId: 1, name: "Test Monitor 2", type: "API", url: "", regex: "", status: nil),
            Monitor(id: 3, applicationId: 1, name: "Test Monitor 3", type: "WEB", url: "", regex: "", status: nil),
            Monitor(id: 4, applicationId: 1, name: "Test Monitor 4", type: "API", url: "", regex: "", status: nil)
        ]
        startDate = Calendar.current.date(byAdding: .hour, value: -12, to: Date())!
        endDate = Date()
        previewHistoryData = [
            "1": [Status(dateRecorded: startDate, milliseconds: 1, status: true, attempts: 1, statusCode: 200),
                Status(dateRecorded: endDate, milliseconds: 1, status: true, attempts: 1, statusCode: 200)],
            "2": [Status(dateRecorded: startDate, milliseconds: 1, status: true, attempts: 1, statusCode: 200),
                Status(dateRecorded: endDate, milliseconds: 1, status: true, attempts: 1, statusCode: 200)],
            "3": [Status(dateRecorded: startDate, milliseconds: 1, status: true, attempts: 1, statusCode: 200),
                Status(dateRecorded: endDate, milliseconds: 1, status: true, attempts: 1, statusCode: 200)],
            "4": [Status(dateRecorded: startDate, milliseconds: 1, status: true, attempts: 1, statusCode: 200),
                Status(dateRecorded: endDate, milliseconds: 1, status: true, attempts: 1, statusCode: 200)]
        ]
    }
    
    func placeholder(in context: Context) -> MonitorStatusHistoryEntry {
        MonitorStatusHistoryEntry(date: Date(), monitors: previewData, history: previewHistoryData)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> MonitorStatusHistoryEntry {
        MonitorStatusHistoryEntry(date: Date(), monitors: previewData, history: previewHistoryData)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<MonitorStatusHistoryEntry> {
        let newDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
        var entries: [MonitorStatusHistoryEntry] = []
        let monitors = MonitorsService.getMonitorsSyncronous()
        switch monitors {
        case .success(let monitors):
            var monitorsHistory: [String: [Status]] = [:]
            for monitor in monitors {
                let history = MonitorsService.getMonitorHistorySyncronous(applicationId: monitor.applicationId, id: monitor.id, condensed: true)
                switch history {
                case .success(let history):
                    monitorsHistory["\(monitor.applicationId)\(monitor.id)"] = history
                case .failure(let error):
                    print(error)
                }
            }
            entries.append(MonitorStatusHistoryEntry(date: newDate, monitors: monitors, history: monitorsHistory))
        case .failure(let error):
            print(error)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct Data_Otter_iOS_Widget_GraphEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HistoryGraphView(history: getHistoryForGraph())
    }
    
    func getHistoryForGraph() -> [GraphEntry] {
        return entry.monitors.flatMap({ monitor in
            if let historyData = entry.history["\(monitor.applicationId)\(monitor.id)"] {
                return historyData.map({status in
                    GraphEntry(name: monitor.name, taken: status.dateRecorded, status: status.status)
                })
            }
            return []
        })
    }
}

struct Data_Otter_iOS_Widget_Graph: Widget {
    let kind: String = "Data_Otter_iOS_Widget_Graph"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            Data_Otter_iOS_Widget_GraphEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Data Otter Graph")
        .description("A graph widget to show up up/down status history.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    Data_Otter_iOS_Widget_Graph()
} timeline: {
    MonitorStatusHistoryEntry(date: Date(), monitors: [], history: [:])
}
