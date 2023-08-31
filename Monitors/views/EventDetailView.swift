//
//  EventDetailView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/31/23.
//

import SwiftUI

struct EventDetailView: View {
    
    let event: Event
    
    var body: some View {
        VStack {
            Text(event.monitor).font(.title)
            Text(event.currentStatus ? "Online" : "Offline").foregroundColor(event.currentStatus ? .green : .red)
            
            Form {
                Section("Log"){
                    ForEach (event.entries.sorted(by: >)){entry in
                        HStack {
                            Text(convertToTime(date: entry.time))
                            Spacer()
                            Text(entry.status ? "Online" : "Offline").foregroundColor(entry.status ? .green : .red)
                        }
                    }
                }
            }
        }
    }
    
    
    func convertToTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}
