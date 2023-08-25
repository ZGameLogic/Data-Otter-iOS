//
//  ContentView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/20/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MonitorsGeneralView().tabItem({
                Label("Monitors", systemImage: "chart.bar.doc.horizontal")
            }).tag(1)
            EventsListView().tabItem({
                Label("Events", systemImage: "megaphone")
            }).tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
