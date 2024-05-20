//
//  GroupsView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/17/24.
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
    @State var showAddGroup = false
    @State var groupToDelete: MonitorGroup? = nil
    @State var showDeleteGroup = false
    @State var showDeleteError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Groups"){
                    ForEach(viewModel.groups){ group in
                        NavigationLink(value: group) {
                            GroupListView(name: group.name, count: group.monitors.count, status: true)
                        }.swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                groupToDelete = group
                                showDeleteGroup = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                historyView
            }.toolbar(){
                ToolbarItem {
                    Button(action: {
                        showAddGroup = true
                    }) {
                        Label("Add Group", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: MonitorGroup.self){ group in
                if let index = viewModel.groups.firstIndex(where: { $0.id == group.id }) {
                    GroupDetailView(group: viewModel.bindingForGroup(at: index))
                }
            }
            .navigationTitle("Groups")
            .refreshable {refreshData()}
            .sheet(isPresented: $showAddGroup, content: {AddGroupView(isPresented: $showAddGroup)})
            .alert(isPresented: $showDeleteGroup) {
                Alert(
                    title: Text("Delete Group"),
                    message: Text("Are you sure you want to delete this Group? This Action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let group = groupToDelete {
                            deleteGroup(group: group)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    var historyView: some View {
        let history = getGroupStatusHistory()
        
        return Section("History") {
            if(history.isEmpty){
                Text("No history to be shown")
            } else {
                Section("History"){
                    HistoryGraphView(history: history)
                }
            }
        }
    }
    
    func getGroupStatusHistory() -> [GraphEntry] {
        var entries = viewModel.groups.compactMap { group in
            // List of dates to get datapoints for for the whole group
            let dates = Set(viewModel.getMonitorsInGroup(group: group).flatMap { monitor in
                viewModel.getMonitorHistoryData(monitor: monitor).map { monitorStatus in
                    monitorStatus.dateRecorded
                }
            }.map { perciseDate in
                let calendar = Calendar.current
                return calendar.date(from: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: perciseDate))!
            }.sorted())
            /*
             TODO
             Make a loop for each date
             Check each monitors status at said date
                the closest status in the past will do here
             create and return a graph entry with the group name, group id, and group status at that specific time
             */
            return "bep"
        }
        
        return []
    }
    
    func deleteGroup(group: MonitorGroup){
        viewModel.deleteGroup(groupId: group.id) { result in
            switch(result){
            case .success():
                print("Success")
            case .failure(let error):
                print(error)
                showDeleteError = true
            }
        }
    }
    
    func refreshData(){
        viewModel.refreshData()
    }
}

#Preview {
    GroupsView()
}