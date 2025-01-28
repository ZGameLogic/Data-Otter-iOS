//
//  Agent List View.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 1/8/25.
//

import SwiftUI

struct AgentListView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    let agent: Agent
    
    var body: some View {
        VStack {
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
            if let his = viewModel.agentStatusHistory[agent.id] {
                if(!his.isEmpty) {
                    ScrollView(.horizontal) {
                        HStack {
                            SmallStatGraph(title: "cpu", history: viewModel.getAgentStatusHistory(agentId: agent.id, stat: .CPU))
                            SmallStatGraph(title: "status", history: viewModel.getAgentStatusHistory(agentId: agent.id, stat: .STATUS))
                            SmallStatGraph(title: "memory", history: viewModel.getAgentStatusHistory(agentId: agent.id, stat: .RAM))
                            SmallStatGraph(title: "disk", history: viewModel.getAgentStatusHistory(agentId: agent.id, stat: .DISK))
                        }
                    }
                }
            }
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
        .environmentObject(DataOtterModel(
        monitorConfigurations: [],
        monitorHistoryData: [:],
        applications: [],
        tags: [],
        rockStats: [:],
        agents: [Agent(id: 1, name: "Mac", os: "MacOS Sonoma", status: AgentStatus(date: Date(), memoryUsage: 34, cpuUsage: 10, diskUsage: 2, agentVersion: "0.0.1"))],
        agentStatusHistory: [1: [
            AgentStatus(date: Date().addingTimeInterval(-12 * 60 * 60), memoryUsage: 12, cpuUsage: 10, diskUsage: 0, agentVersion: "0.0.1"),
            AgentStatus(date: Date(), memoryUsage: 34, cpuUsage: 10, diskUsage: 90, agentVersion: "0.0.1"),
        ]],
        rocks: [:], rockPages: [:]
    ))
}
