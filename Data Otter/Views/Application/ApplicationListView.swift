//
//  ApplicationListView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 8/9/24.
//

import SwiftUI

struct ApplicationListView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    let application: Application
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(application.name)
                .font(.title)
            if(application.status != nil){
                HStack {
                    Label("Status: ", systemImage: "chart.bar.doc.horizontal")
                    Text(application.status! ? "Up": "Down")
                        .foregroundStyle(application.statusColor)
                }
            }
            if(!application.tags.isEmpty){
                Label(application.tags.joined(separator: ", "), systemImage: "tag")
                    .scaledToFit()
            }
        }
    }
}

#Preview {
    List {
        ApplicationListView(application: Application (
            id: 1,
            name: "Discord Bot",
            description: "",
            monitorIds: [0, 1],
            tags: ["Kubernetes", "Discord bot"],
            status: true
        ))
        ApplicationListView(application: Application (
            id: 2,
            name: "Main API",
            description: "",
            monitorIds: [3, 4],
            tags: [],
            status: true
        ))
        ApplicationListView(application: Application (
            id: 1,
            name: "Wraith Bot",
            description: "",
            monitorIds: [],
            tags: ["Kubernetes", "Discord bot"],
            status: nil
        ))
        ApplicationListView(application: Application (
            id: 2,
            name: "Website",
            description: "",
            monitorIds: [],
            tags: [],
            status: nil
        ))
    }.environmentObject(DataOtterModel(
        monitorConfigurations: [],
        monitorHistoryData: [:],
        applications: [],
        tags: [
            Tag(name: "Kubernetes", description: "Anything in the cluster"),
            Tag(name: "Discord bot", description: "A discord bot")
        ]
    ))
}
