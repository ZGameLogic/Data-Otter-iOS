//
//  Data_Otter_iOS_Widget_Graph.swift
//  Data Otter iOS Widget Graph
//
//  Created by Benjamin Shabowski on 5/15/24.
//

import WidgetKit
import SwiftUI
import Charts

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

    struct BinCount: Identifiable {
        let id = UUID()
        let start: Date
        let end: Date
        let count: Int
    }

    var body: some View {
        let bins = computeHalfHourBins()
        VStack(alignment: .leading) {
            if bins.isEmpty {
                Text("No data")
            } else {
                Chart(bins) { bin in
                    BarMark(
                        x: .value("Time", bin.start),
                        y: .value("Monitors Up", bin.count),
                        width: .fixed(10)
                    )
                    .foregroundStyle(.purple)
                }
                // Force the domain to exactly cover our bins to avoid side padding
                .chartXScale(domain: (bins.first?.start ?? entry.date)...(bins.last?.end ?? entry.date))
                // Keep labels minimal to reduce clutter and wasted space
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.hour(), centered: true)
                    }
                }
                .chartYScale(domain: 0...max(1, maxUpCount(in: bins)))
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                Text("Updated \(Date.now.formatted(date: .omitted, time: .shortened))").font(.caption2)
                    .fontWeight(.ultraLight)
            }
        }
    }

    private func computeHalfHourBins() -> [BinCount] {
        let now = entry.date
        let start = Calendar.current.date(byAdding: .hour, value: -12, to: now) ?? now

        // Build 24 contiguous 30-minute bins
        var bins: [BinCount] = []
        var cursor = start
        let allMonitors = entry.monitors

        // Pre-group history by monitor id key for quick access
        // Key format used elsewhere is "\(applicationId)\(id)"
        var historyByMonitor: [String: [Status]] = [:]
        for monitor in allMonitors {
            let key = "\(monitor.applicationId)\(monitor.id)"
            if let list = entry.history[key] {
                // ensure sorted by date
                let sorted = list.sorted { $0.dateRecorded < $1.dateRecorded }
                historyByMonitor[key] = sorted
            } else {
                historyByMonitor[key] = []
            }
        }

        for _ in 0..<24 {
            let binStart = cursor
            let binEnd = Calendar.current.date(byAdding: .minute, value: 30, to: binStart) ?? binStart

            var upCount = 0
            for monitor in allMonitors {
                let key = "\(monitor.applicationId)\(monitor.id)"
                if let statuses = historyByMonitor[key] {
                    // Find any status samples within [binStart, binEnd)
                    // If any sample indicates down (status == false), consider it down for the bin.
                    // Otherwise if there is at least one sample and all are up, count as up.
                    // If there are no samples for the bin, we conservatively treat as down.
                    // Modified logic per instructions:
                    
                    // Find if any down occurred inside the bin
                    let wentDownInBin = statuses.contains(where: { $0.dateRecorded >= binStart && $0.dateRecorded < binEnd && $0.status == false })

                    // Find last known status before binEnd
                    let lastKnown = statuses.last(where: { $0.dateRecorded < binEnd })?.status

                    // Decide up/down for this bin:
                    // - If any down occurred inside the bin, treat as down
                    // - Else if we have a last known status up, treat as up
                    // - Else if there is no prior status yet (nil), treat as up (assume full height for missing data)
                    // - Else treat as down
                    if wentDownInBin {
                        // down
                    } else if let lastKnown = lastKnown, lastKnown == true {
                        upCount += 1
                    } else if lastKnown == nil {
                        // No data yet for this monitor up to binEnd: assume up
                        upCount += 1
                    } else {
                        // lastKnown is false
                    }
                }
            }

            bins.append(BinCount(start: binStart, end: binEnd, count: upCount))
            cursor = binEnd
        }

        return bins
    }

    private func maxUpCount(in bins: [BinCount]) -> Int {
        bins.map { $0.count }.max() ?? 0
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
