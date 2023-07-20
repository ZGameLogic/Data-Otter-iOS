//
//  GuageView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/21/23.
//

import SwiftUI
import WidgetKit

struct GuageView: View {
    @Environment(\.widgetFamily) var family
    let entry: MonitorStatusEntry
    
    var body: some View {
        if(entry.hasOnlinePlayers() && entry.downMonitors.isEmpty && family == .accessoryCircular){
            VStack {
                Text("\(entry.onlinePlayers)").foregroundColor(.purple)
                Gauge(value: Double(entry.up), in: 0...Double(entry.total)) {}
                currentValueLabel: {
                Text(entry.up, format: .number).foregroundColor(entry.down == 0 ? .green : .red)
                }
            .tint(entry.down == 0 ? .green : .red)
            .scaleEffect(0.75)
            }
        } else {
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
}

struct GuageView_Previews: PreviewProvider {
    static var previews: some View {
        GuageView(entry: MonitorStatusEntry(date: Date(), monitors: Monitor.previewArrayAllGood(), historyData: [])).previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
