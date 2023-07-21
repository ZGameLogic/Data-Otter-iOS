//
//  PlayerHistoryGraphView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 7/21/23.
//

import SwiftUI
import Charts

struct PlayerHistoryGraphView: View {
    
    let history: [Monitor]
    
    var body: some View {
        Chart(history) {
            LineMark(
                x: .value("Time", $0.taken),
                y: .value("Online", $0.online ?? 0)
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
        .chartYAxis {
            AxisMarks(values: [0, 5, 10, 15])
        }
    }
}

struct PlayerHistoryGraphView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerHistoryGraphView(history: Monitor.previewHistoryData())
    }
}
