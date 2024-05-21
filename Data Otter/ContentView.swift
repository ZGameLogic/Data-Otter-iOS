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
            GeneralView().tabItem({
                Label("Monitors", systemImage: "chart.bar.doc.horizontal")
            }).tag(0)
            EventsView(monitorData: [], monitorHistoryData: [:]).tabItem({
                Label("Events", systemImage: "megaphone")
            }).tag(1)
            GroupsView().tabItem({
                Label("Groups", systemImage: "rectangle.3.group")
            }).tag(2)
        }
        .onReceive(NotificationCenter.default.publisher(for: .monitorSelected)) { notification in
            print("Notication \(notification)")
            if notification.object is Int {
                DispatchGroup().notify(queue: .main) {
                    selectedTab = 0
                }
            }
        }.environmentObject(DataOtterModel())
    }
}

#Preview {
    ContentView()
}
