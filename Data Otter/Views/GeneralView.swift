//
//  GeneralView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct GeneralView: View {
    @State var monitorData: [MonitorStatus]
    @State var monitorHistoryData: [Int: [Status]]
    @State var groups: [MonitorGroup]
    @State private var showAddMonitor = false
    @State private var showAlert = false
    
    @State var monitorToDelete: MonitorStatus? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(monitorData){monitor in
                    NavigationLink(value: monitor) {
                        MonitorListView(monitor: monitor, groups: groups)
                    }.swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            monitorToDelete = monitor
                            showAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                
                if(!monitorHistoryData.isEmpty){
                    Section("History"){
                        HistoryGraphView(monitorData: monitorData, monitorHistoryData: monitorHistoryData)
                    }
                }
            }
            .navigationTitle("Monitors")
                .navigationDestination(for: MonitorStatus.self) { monitor in
                    if let index = monitorData.firstIndex(where: { $0.id == monitor.id }) {
                        MonitorDetailView(monitor: $monitorData[index], history: monitorHistoryData[monitorData[index].id] ?? [], groups: groups)
                    }
                }
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
                    fetchMonitorGroups()
                    fetchMonitorStatus()
                }
        }.onAppear {
            fetchMonitorGroups()
            fetchMonitorStatus()
        }.onChange(of: monitorHistoryData) { old, new in
            print("Old: \(old) \nNew: \(new)")
        }.sheet(isPresented: $showAddMonitor, onDismiss: {
            fetchMonitorGroups()
            fetchMonitorStatus()
        }, content: {
            AddMonitorView(isPresented: $showAddMonitor)
        })
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete monitor"),
                message: Text("Are you sure you want to delete this monitor? This Action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    if let monitor = monitorToDelete {
                        deleteMonitor(monitor: monitor)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func deleteMonitor(monitor: MonitorStatus){
        MonitorsService.deleteMonitor(monitorId: monitor.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    monitorHistoryData.removeValue(forKey: monitor.id)
                    monitorToDelete = nil
                    fetchMonitorStatus()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchMonitorGroups () {
        print("Fetching monitor groups")
        MonitorsService.getMonitorGroups { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    groups = data
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchMonitorsHistory() {
           print("Fetching monitor history")
           let dispatchGroup = DispatchGroup()
           var tempHistoryData: [Int: [Status]] = [:]

           for monitor in monitorData {
               dispatchGroup.enter()
               MonitorsService.getMonitorHistory(id: monitor.id, condensed: true) { result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success(let data):
                           tempHistoryData[monitor.id] = data
                       case .failure(let error):
                           print(error)
                       }
                       dispatchGroup.leave()
                   }
               }
           }

           dispatchGroup.notify(queue: .main) {
               self.monitorHistoryData = tempHistoryData
               print("All history data fetched and updated")
           }
       }
    
    func fetchMonitorStatus() {
        print("Fetching monitor data")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        MonitorsService.getMonitorsWithStatus { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    monitorData = data
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            fetchMonitorsHistory()
        }
    }
}

#Preview {
    GeneralView(monitorData: [
        MonitorStatus(id: 1, name: "Test Monitor 1", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 1, statusCode: 200), groups: []),
        MonitorStatus(id: 2, name: "Test Monitor 2", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: false, attempts: 3, statusCode: 200), groups: [])
    ], monitorHistoryData: [:], groups: [])
}
