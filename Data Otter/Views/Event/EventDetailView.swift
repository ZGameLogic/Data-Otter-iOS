//
//  EventDetailView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/14/24.
//

import SwiftUI

struct EventDetailView: View {
    let event: MonitorEvent
    
    var body: some View {
        VStack {
            Text(event.name).font(.title)
            Text(event.eventStatus ? "Online" : "Offline").foregroundStyle(event.eventStatus ? .green : .red)
            List {
                Section("Log") {
                    ForEach(event.log){ entry in
                        HStack {
                            Text("\(formatTime(entry.date))")
                            Spacer()
                            Text(entry.status ? "Online" : "Offline").foregroundStyle(entry.status ? .green : .red)
                        }
                    }
                }
            }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
