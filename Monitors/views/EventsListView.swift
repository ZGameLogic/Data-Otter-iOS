//
//  EventsListView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/25/23.
//

import SwiftUI

struct EventsListView: View {
    @State var events: [Events] = []
    @State var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State var endDate = Date()
    
    var body: some View {
        NavigationStack {
            HStack {
                Spacer()
                DatePicker("", selection: $startDate, in: ...endDate, displayedComponents: [.date])
                Spacer()
                Text(" to ")
                Spacer()
                DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date])
                Spacer()
            }.labelsHidden()
            List {
                if(events.isEmpty){
                    Text("No events found in the time frame given")
                } else {
                    ForEach(events, id: \.self.time){events in
                        Section(formatDate(date: events.time)){
                            ForEach(events.events, id:\.self.monitor){monitor in
                                Text("\(monitor.monitor) \(monitor.status ? "came up" : "went down")").foregroundColor(monitor.status ? Color.green : Color.red)
                            }
                        }
                    }
                }
            }
            .refreshable {
                await refresh()
            }
            .navigationTitle("Events")
        }
        .task {
            await refresh()
        }
        .onChange(of: startDate, perform: {_ in Task {await refresh()}})
        .onChange(of: endDate, perform: {_ in Task {await refresh()}})
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a MM-dd-yyyy"
        return formatter.string(from: date)
    }
    
    func refresh() async {
        do {
            events = try await fetch(startDate: startDate, endDate: endDate)
        } catch networkError.inavlidURL {
            print("u")
        } catch networkError.invalidData {
            print("d")
        } catch networkError.inavlidResponse {
            print("r")
        } catch {
            print("huh")
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
    }
}
