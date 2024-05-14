//
//  EventsListView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct EventsListView: View {
    var event: MonitorEvent
    
    var body: some View {
        HStack {
            VStack{
                HStack {
                    Text(event.name)
                    Spacer()
                }
                HStack {
                    Text("\(formatTime(date: event.start)) - \(formatTime(date: event.end))").font(.caption2)
                    Spacer()
                }
            }
            Spacer()
            Text(event.eventStatus ? "Online" : "Offline").foregroundColor(event.eventStatus ? Color.green : Color.red)
        }
    }
    
    func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

