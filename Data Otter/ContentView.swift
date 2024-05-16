//
//  ContentView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GeneralView(monitorData: [], monitorHistoryData: [:], groups: []).tabItem({
                Label("Monitors", systemImage: "chart.bar.doc.horizontal")
            }).tag(0)
            EventsView(monitorData: [], monitorHistoryData: [:]).tabItem({
                Label("Events", systemImage: "megaphone")
            }).tag(1)
        }
    }
}

#Preview {
    ContentView()
}
