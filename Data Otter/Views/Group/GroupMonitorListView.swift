//
//  GroupMonitorListView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/19/24.
//

import SwiftUI

struct GroupMonitorListView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    @State var monitorToggles: [MonitorToggle] = []
    @Binding var group: MonitorGroup
    
    var body: some View {
        Form {
            Section("Monitors"){
                ForEach($monitorToggles.indices, id: \.self) { index in
                    Toggle(isOn: $monitorToggles[index].isSelected) {
                        Text("\(monitorToggles[index].name)")
                    }
                    .onChange(of: monitorToggles[index].isSelected) { _, newValue in
                        onToggleChange(newValue: newValue, toggle: monitorToggles[index])
                    }
                }
            }
        }.onAppear {
            monitorToggles = viewModel.monitorConfigurations.map{ monitor in
                MonitorToggle(id: monitor.id, name: monitor.name, isSelected: group.monitors.contains(where: {$0 == monitor.id}))
            }
        }
    }
    
    func onToggleChange(newValue: Bool, toggle: MonitorToggle){
        if(newValue){
            viewModel.addMonitorToGroup(monitorId: toggle.id, groupId: group.id) { _ in
                
            }
        } else {
            viewModel.removeMonitorFromGroup(monitorId: toggle.id, groupId: group.id) { _ in
                
            }
        }
    }
}
