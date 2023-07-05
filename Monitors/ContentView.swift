//
//  ContentView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/20/23.
//

import SwiftUI

struct ContentView: View {
    @State var monitors: [Monitor] = []
    @State var showAddMonitor = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(monitors.sorted()){monitor in
                    NavigationLink(value: monitor) {
                        MonitorListView(monitor: monitor)
                    }
                }
            }.navigationTitle("Monitors")
                .navigationDestination(for: Monitor.self, destination: { MonitorDetailView(monitors: $monitors, id: $0.id, title: true)})
                .toolbar {
                    ToolbarItem {
                        Button(action: {
                            showAddMonitor = true
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
            }
            .refreshable {
                await refresh()
            }
        }
        .sheet(isPresented: $showAddMonitor, content: {
            AddMonitorView(showing: $showAddMonitor)
        })
        .onChange(of: showAddMonitor, perform: {newValue in
            if(!newValue){
                Task {
                    await refresh()
                }
            }
        })
        .padding()
        .task {
            await refresh()
        }
    }
    
    func refresh() async {
        do {
            monitors = try await fetch()
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
