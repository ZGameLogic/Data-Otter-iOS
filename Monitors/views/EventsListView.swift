//
//  EventsListView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/25/23.
//

import SwiftUI

struct EventsListView: View {
    @State var events: [Event] = []
    @State var searched = ""
    
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
                    ForEach(getDayDates(events: events).sorted(by: >), id: \.self) { day in
                        if(!events.filter{
                            let trimmedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: $0.startTime))!
                            return trimmedDate == day && ($0.monitor.lowercased().contains(searched.lowercased()) || searched.isEmpty)
                        }.isEmpty){
                            Section(formatDate(date: day)) {
                                ForEach(events.filter{
                                    let trimmedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: $0.startTime))!
                                    return trimmedDate == day
                                }) { event in
                                    if(searched.isEmpty || event.monitor.lowercased().contains(searched.lowercased())){
                                        NavigationLink {
                                            EventDetailView(event: event)
                                        } label: {
                                            HStack {
                                                VStack{
                                                    HStack {
                                                        Text(event.monitor)
                                                        Spacer()
                                                    }
                                                    HStack {
                                                        Text("\(formatTime(date: event.startTime)) - \(formatTime(date: event.endTime))").font(.caption2)
                                                        Spacer()
                                                    }
                                                }
                                                Spacer()
                                                Text(event.currentStatus ? "Online" : "Offline").foregroundColor(event.currentStatus ? Color.green : Color.red)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .refreshable {
                await refresh()
            }
            .navigationTitle("Events")
        }.searchable(text: $searched)
        .task {
            await refresh()
        }
        .onChange(of: startDate, perform: {_ in Task {await refresh()}})
        .onChange(of: endDate, perform: {_ in Task {await refresh()}})
    }
    
    func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
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
