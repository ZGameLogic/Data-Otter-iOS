//
//  GeneralView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct GeneralView: View {
    @EnvironmentObject var viewModel: Monitors
    
    @State private var showAddMonitor = false
    @State private var showAlert = false
    @State var monitorToDelete: MonitorStatus? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.monitorConfigurations){monitor in
                    NavigationLink(value: monitor) {
                        MonitorListView(monitor: monitor, groups: viewModel.groups)
                    }.swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            monitorToDelete = monitor
                            showAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                
                if(!viewModel.monitorHistoryData.isEmpty){
                    Section("History"){
                        HistoryGraphView(monitorData: viewModel.monitorConfigurations, monitorHistoryData: viewModel.monitorHistoryData)
                    }
                }
            }
            .navigationTitle("Monitors")
                .navigationDestination(for: MonitorStatus.self) { monitor in
                    if let index = viewModel.monitorConfigurations.firstIndex(where: { $0.id == monitor.id }) {
                        MonitorDetailView(monitor: viewModel.bindingForMonitor(at: index), history: viewModel.monitorHistoryData[viewModel.monitorConfigurations[index].id] ?? [], groups: viewModel.groups)
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
                    viewModel.refreshData()
                }
        }.onChange(of: viewModel.monitorConfigurations) { old, new in
            print("Old: \(old) \nNew: \(new)")
        }.sheet(isPresented: $showAddMonitor, onDismiss: {
            viewModel.refreshData()
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
                    viewModel.monitorHistoryData.removeValue(forKey: monitor.id)
                    monitorToDelete = nil
                    viewModel.refreshData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

//#Preview {
//    GeneralView(monitorData: [
//        MonitorStatus(id: 1, name: "Test Monitor 1", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 1, statusCode: 200), groups: []),
//        MonitorStatus(id: 2, name: "Test Monitor 2", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: false, attempts: 3, statusCode: 200), groups: [])
//    ], monitorHistoryData: [:], groups: [])
//}
