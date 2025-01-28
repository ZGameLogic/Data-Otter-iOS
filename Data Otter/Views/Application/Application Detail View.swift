//
//  Application Detail View.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 9/3/24.
//

import SwiftUI

struct ApplicationDetailView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    let application: Application
    
    var body: some View {
        List {
            Section("Data") {
                Text("ID: \(application.id)")
                if let desc = application.description {
                    Text(desc)
                }
                Text("Tags: \(application.tags.joined(separator: ", "))")
                Text("Monitors: \(application.monitorIds.count)")
            }
            NavigationLink(value: application.id) {
                Text("Rocks")
            }
        }.navigationTitle("\(application.name)")
        .navigationDestination(for: Int64.self) { appId in
            RockGeneralView(appId: appId)
        }
    }
}

#Preview {
    ApplicationDetailView(application: Application(id: 1, name: "Test Application", description: "Boom a huge description", monitorIds: [], tags: [], status: nil))
}
