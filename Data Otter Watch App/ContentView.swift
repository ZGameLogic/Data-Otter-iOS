//
//  ContentView.swift
//  Monitors Watch App
//
//  Created by Benjamin Shabowski on 7/4/23.
//

import SwiftUI

struct ContentView: View {
    @State var monitors: [Monitor] = []
    @State var refreshing = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(monitors.sorted()){monitor in
                    NavigationLink(value: monitor) {
                        MonitorListView(monitor: monitor)
                    }
                }
                Button("Refresh"){
                    monitors = []
                    refreshing = true
                    Task {
                        await refresh()
                    }
                }.disabled(refreshing)
            }.navigationTitle("Monitors")
                .navigationDestination(for: Monitor.self, destination: { MonitorDetailView(monitors: $monitors, id: $0.id, title: false)})
        }
        .task {
            await refresh()
        }
    }
    
    func refresh() async {
        do {
            monitors = try await fetch()
            refreshing = false
        } catch networkError.inavlidURL {
            print("u")
        } catch networkError.invalidData {
            print("d")
        } catch networkError.inavlidResponse {
            print("r")
        } catch {
            print("huh")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(monitors: Monitor.previewArray())
    }
}
