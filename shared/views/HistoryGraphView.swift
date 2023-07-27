//
//  AllHistoryGraphView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 7/20/23.
//

import SwiftUI
import Charts

struct HistoryGraphView: View {
    let history: [Monitor]
    
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
                        Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
                        Calendar.current.date(byAdding: .hour, value: -6, to: Date())!,
                        Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
                        Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                        Date()
                    ]
                )
            }
            HStack {
                Text("Updated \(Date.now.formatted(date: .omitted, time: .shortened))").font(.caption2)
                    .fontWeight(.ultraLight)
                Spacer()
            }
        }
    }
}

struct AllHistoryGraphView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryGraphView(history: Monitor.previewHistoryData())
    }
}
