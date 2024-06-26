//
//  MonitorListView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct MonitorListView: View {
    let monitor: MonitorStatus
    let groups: [MonitorGroup]

    var body: some View {
        VStack(alignment: .leading){
            Text(monitor.name).foregroundStyle(monitor.getStatusColor())
            if(!monitor.groups.isEmpty){
                Text("\(getGroups(monitorGroups: monitor.groups, groups: groups))").font(.footnote).italic()
            }
            Text(monitor.type).font(.footnote)
        }
    }
    
    func getGroups(monitorGroups: [Int], groups: [MonitorGroup]) -> String {
        let names = monitorGroups.isEmpty ? "none" : monitorGroups.compactMap { id in
            groups.first(where: { $0.id == id })?.name
        }.joined(separator: ", ")
        
        return names
    }
}

#Preview {
    MonitorListView(monitor: MonitorStatus(id: 1, name: "Test Monitor", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 1, statusCode: 200), groups: [1]), groups: [MonitorGroup(id: 1, name: "Test", monitors: [1])])
}
