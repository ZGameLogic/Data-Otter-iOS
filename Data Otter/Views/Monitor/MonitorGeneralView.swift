//
//  GeneralView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct GeneralView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
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
        viewModel.deleteMonitor(monitorId: monitor.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    monitorToDelete = nil
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
