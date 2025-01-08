//
//  Small Stat Graph.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 1/8/25.
//

import SwiftUI
import Charts

struct SmallStatGraph: View {
    let title: String
    let history: [SmallStat]
    var body: some View {
        Chart(history.sorted()) {
            LineMark(
                x: .value("Time", $0.date),
                y: .value("Name", $0.value)
            ).foregroundStyle(by: .value("Name", title))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .padding(5)
        .frame(width: 100, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
        )
    }
}

struct SmallStat: Identifiable, Comparable {
    var id: Double
    
    static func < (lhs: SmallStat, rhs: SmallStat) -> Bool {
        return lhs.date < rhs.date
    }
    
    let date: Date
    let value: Int64
    
    init(date: Date, value: Int64) {
        self.id = date.timeIntervalSince1970
        self.date = date
        self.value = value
    }
}

#Preview {
    SmallStatGraph(title: "stat", history: [
        SmallStat(date: Date().addingTimeInterval(-12 * 60 * 60), value: 0),
        SmallStat(date: Date().addingTimeInterval(-9 * 60 * 60), value: 34),
        SmallStat(date: Date().addingTimeInterval(-60 * 60), value: 50),
        SmallStat(date: Date(), value: 100)
    ])
}
