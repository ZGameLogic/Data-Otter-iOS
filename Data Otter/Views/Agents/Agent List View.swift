//
//  Agent List View.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 1/8/25.
//

import SwiftUI

struct AgentListView: View {
    let agent: Agent
    
    var body: some View {
        HStack {
            Label("", systemImage: "laptopcomputer")
                .foregroundStyle(agent.status != nil ? Color("UpStatusColor") : Color("DownStatusColor"))
            VStack(alignment: .leading) {
                Text(agent.name).font(.title)
                if let status = agent.status {
                    Text("Reported: \(formattedDate(date: status.date))")
                }
            }
            Spacer()
        }
    }
    
    func formattedDate(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM HH:mm"
            return formatter.string(from: date)
        }
}

#Preview {
    AgentListView(agent: Agent(id: 1, name: "Mac", os: "MacOS Sonoma", status: nil))
}

#Preview {
    AgentListView(agent: Agent(id: 1, name: "Mac", os: "MacOS Sonoma", status: AgentStatus(date: Date(), memoryUsage: 34, cpuUsage: 10, diskUsage: 2, agentVersion: "0.0.1")))
}
