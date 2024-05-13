//
//  MonitorListView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct MonitorListView: View {
    let monitor: MonitorStatus
    
    var body: some View {
        VStack {
            HStack {
                Text(monitor.name).foregroundColor(monitor.getStatusColor())
                Spacer()
            }
            HStack {
                Text(monitor.type)
                Spacer()
            }.font(.footnote)
        }
    }
}

#Preview {
    MonitorListView(monitor: MonitorStatus(id: 1, name: "Test Monitor", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 1, statusCode: 200)))
}
