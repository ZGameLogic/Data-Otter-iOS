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
        VStack{
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
                        Calendar.current.date(byAdding: .hour, value: -12, to: Date())!,
                        Calendar.current.date(byAdding: .hour, value: -9, to: Date())!,
                        Calendar.current.date(byAdding: .hour, value: -6, to: Date())!,
                        Calendar.current.date(byAdding: .hour, value: -3, to: Date())!,
                        Date()
                    ]
                )
            }.chartYScale(domain: 0...20)
            HStack {
                Text("Updated \(Date.now.formatted(date: .omitted, time: .shortened))").font(.caption2)
                    .fontWeight(.ultraLight)
                Spacer()
            }
        }
    }
}

struct PlayerHistoryGraphView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerHistoryGraphView(history: Monitor.previewHistoryData())
    }
}
