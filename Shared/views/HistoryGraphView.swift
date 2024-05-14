//
//  HistoryGraphView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/14/24.
//

import SwiftUI
import Charts

struct HistoryGraphView: View {
   let history: [GraphEntry]
    
    init(monitorData: MonitorStatus, monitorHistoryData: [Status]){
        let name = monitorData.name
        history = monitorHistoryData.map { status in
            GraphEntry(name: name, taken: status.dateRecorded, status: status.status)
        }
    }
    
    init(monitorData: [MonitorStatus], monitorHistoryData: [Int : [Status]]) {
        history = monitorHistoryData.flatMap { key, statuses in
            let name = monitorData.first(where: { $0.id == key })!.name
            return statuses.map { status in
                GraphEntry(name: name, taken: status.dateRecorded, status: status.status)
            }
        }
        for thing in history {
            print(thing)
        }
    }
    
    var body: some View {
            VStack {
                Chart(history) {
                    LineMark(
                        x: .value("Time", $0.taken),
                        y: .value("Name", $0.status ? "Online" : "Offline")
                    )
                    .foregroundStyle(by: .value("Name", $0.name))
                }
                .chartXAxis {
                    AxisMarks(
                        format: Date.FormatStyle().hour().minute(),
                        values: [
                            Calendar.current.date(byAdding: .hour, value: -12, to: Date())!,
                            Calendar.current.date(byAdding: .hour, value: -9, to: Date())!,
                            Calendar.current.date(byAdding: .hour, value: -6, to: Date())!,
                            Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
                            Date()
                        ]
                    )
                }.chartYScale(domain: ["Online", "Offline"])
                HStack {
                    Text("Updated \(Date.now.formatted(date: .omitted, time: .shortened))").font(.caption2)
                        .fontWeight(.ultraLight)
                    Spacer()
                }
            }
        }
}

struct GraphEntry: Identifiable, Comparable {
    static func < (lhs: GraphEntry, rhs: GraphEntry) -> Bool {
        lhs.taken < rhs.taken
    }
    
    let id: String
    let name: String
    let taken: Date
    let status: Bool
    
    init(name: String, taken: Date, status: Bool) {
        self.id = "\(name)\(taken)\(status)"
        self.name = name
        self.taken = taken
        self.status = status
    }
}

#Preview {
    HistoryGraphView(monitorData: [], monitorHistoryData: [:])
}
