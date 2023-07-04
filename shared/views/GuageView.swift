//
//  GuageView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/21/23.
//

import SwiftUI

struct GuageView: View {
    let entry: MonitorStatusEntry
    
    var body: some View {
        Gauge(value: Double(entry.up), in: 0...Double(entry.total)) {}
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
