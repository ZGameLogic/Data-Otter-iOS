//
//  MonitorsGeneralView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 7/21/23.
//

import SwiftUI

struct MonitorsGeneralView: View {
    @State var monitors: [Monitor] = []
    @State var allHistoryData: [Monitor] = []
    @State var showAddMonitor = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(monitors.sorted()){monitor in
                    NavigationLink(value: monitor) {
                        MonitorListView(monitor: monitor)
                    }
                }
                if(!allHistoryData.isEmpty){
                    if(allHistoryData.contains{$0.online ?? 0 > 0}){
                        Section("Players online"){
                            PlayerHistoryGraphView(history: allHistoryData.filter{$0.type == "minecraft"})
                        }
                    }
                    Section("History"){
                        HistoryGraphView(history: allHistoryData)
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
            allHistoryData = try await fetchHistory()
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

struct MonitorsGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorsGeneralView()
    }
}