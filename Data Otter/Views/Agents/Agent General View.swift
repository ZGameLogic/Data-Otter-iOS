//
//  Agent General View.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 1/8/25.
//

import SwiftUI

struct AgentGeneralView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach (viewModel.agents){agent in
                    AgentListView(agent: agent)
                }
            }.navigationTitle("Agents")
        }
    }
}

#Preview {
    AgentGeneralView()
}
