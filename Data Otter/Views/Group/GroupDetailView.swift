//
//  GroupDetailView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/19/24.
//

import SwiftUI

struct GroupDetailView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    @Binding var group: MonitorGroup
    
    @State var monitorToggles: [MonitorToggle] = []
    
    var body: some View {
        Form {
            Section("Monitors"){
                if(viewModel.getMonitorsInGroup(group: group).isEmpty){
                    Text("No monitors assigned to group")
                }
                ForEach(viewModel.getMonitorsInGroup(group: group)) { monitor in
                    VStack(alignment: .leading){
                        Text(monitor.name).foregroundStyle(monitor.getStatusColor())
                        Text(monitor.type).font(.footnote)
                    }
                }
                NavigationLink("Edit Monitors") { GroupMonitorListView(group: $group) }
            }
            if(viewModel.getMonitorsInGroup(group: group).contains(where: {$0.status != nil})){
                Section("History"){
                    HistoryGraphView(monitorData: viewModel.getMonitorsInGroup(group: group), monitorHistoryData: viewModel.monitorHistoryData)
                }
            }
        }.navigationTitle("\(group.name)").navigationBarTitleDisplayMode(.inline)
    }
    
    func getMonitors() -> String {
        let names = viewModel.monitorConfigurations.filter({$0.groups.contains { monitorGroupId in
            monitorGroupId == group.id
        }}).map { $0.name }
        return names.isEmpty ? "None" : names.joined(separator: ", ")
    }
}
