//
//  GeneralView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct MonitorGeneralView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
    @State private var showAddMonitor = false
    @State private var showAlert = false
    @State var monitorToDelete: Monitor? = nil
    
    @State var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                if(viewModel.monitorStatusLoading){
                    MonitorListSkeleton()
                    MonitorListSkeleton()
                    MonitorListSkeleton()
                } else if(!viewModel.monitorStatusLoading && viewModel.monitorConfigurations.isEmpty) {
                    ContentUnavailableView("No monitor data available", systemImage: "chart.bar.doc.horizontal", description: Text("User the + icon to add a new monitor"))
                } else {
                    ForEach(viewModel.monitorConfigurations){monitor in
                        NavigationLink(value: monitor) {
                            MonitorListView(monitor: monitor)
                        }.swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                monitorToDelete = monitor
                                showAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }.onReceive(NotificationCenter.default.publisher(for: .monitorSelected)) { notification in
                            if let monitorID = notification.object as? Int, let selectedMonitor = viewModel.getMonitorById(monitorID) {
                                navigationPath.removeLast(navigationPath.count)
                                navigationPath.append(selectedMonitor)
                            }
                        }
                    }
                    
                    if(!viewModel.monitorHistoryData.isEmpty){
                        Section("History"){
                            HistoryGraphView(history: getHistoryForGraph())
                        }
                    }
                }
            }
            .navigationTitle("Monitors")
                .navigationDestination(for: Monitor.self) { monitor in
                    if let index = viewModel.monitorConfigurations.firstIndex(where: { $0.id == monitor.id }) {
                        MonitorDetailView(monitor: viewModel.bindingForMonitor(at: index), history: viewModel.monitorHistoryData[viewModel.monitorConfigurations[index].id] ?? [])
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
    
    func getHistoryForGraph() -> [GraphEntry] {
        return viewModel.monitorConfigurations.flatMap({ monitor in
            if let historyData = viewModel.monitorHistoryData[monitor.id] {
                return historyData.map({status in
                    GraphEntry(name: monitor.name, taken: status.dateRecorded, status: status.status)
                })
            }
            return []
        })
    }
    
    func deleteMonitor(monitor: Monitor){
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
