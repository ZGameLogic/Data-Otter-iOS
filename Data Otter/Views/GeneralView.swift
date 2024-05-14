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
    @State private var showAddMonitor = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(monitorData){monitor in
                    NavigationLink(value: monitor) {
                        MonitorListView(monitor: monitor)
                    }
                }
            }.navigationTitle("Monitors")
                .navigationDestination(for: MonitorStatus.self) { monitor in
                    if let index = monitorData.firstIndex(where: { $0.id == monitor.id }) {
                        MonitorDetailView(monitor: $monitorData[index], history: monitorHistoryData[monitorData[index].id] ?? [])
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
                    fetchMonitorsHistory()
                }
        }.onAppear {
            fetchMonitorStatus()
        }.onChange(of: monitorHistoryData) { old, new in
            print("Old: \(old) \nNew: \(new)")
        }
    }
    
    func fetchMonitorsHistory() {
           print("Fetching monitor history")
           let dispatchGroup = DispatchGroup()
           var tempHistoryData: [Int: [Status]] = [:]

           for monitor in monitorData {
               dispatchGroup.enter()
               MonitorsService.getMonitorHistory(id: monitor.id) { result in
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
        MonitorStatus(id: 1, name: "Test Monitor 1", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 1, statusCode: 200)),
        MonitorStatus(id: 2, name: "Test Monitor 2", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: false, attempts: 3, statusCode: 200))
    ], monitorHistoryData: [:])
}
