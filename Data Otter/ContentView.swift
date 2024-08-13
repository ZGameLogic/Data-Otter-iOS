//
//  ContentView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ApplicationGeneralView().tabItem({
                Label("Applications", systemImage: "laptopcomputer")
            }).tag(0)
            MonitorGeneralView().tabItem({
                Label("Monitors", systemImage: "chart.bar.doc.horizontal")
            }).tag(1)
            EventsView(monitorData: [], monitorHistoryData: [:]).tabItem({
                Label("Events", systemImage: "megaphone")
            }).tag(2)
        }
        .onReceive(NotificationCenter.default.publisher(for: .monitorSelected)) { notification in
            print("Notication \(notification)")
            if notification.object is Int {
                DispatchGroup().notify(queue: .main) {
                    selectedTab = 1
                }
            }
        }.environmentObject(DataOtterModel())
    }
}

#Preview {
    ContentView()
}
