//
//  EventsView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/14/24.
//

import SwiftUI

struct EventsView: View {
    @State var monitorData: [MonitorStatus]
    @State var monitorHistoryData: [Int: [Status]]

    @State var events: [MonitorEvent] = []
    @State var monitorToggles: [MonitorToggle] = []
    
    @State var startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State var endDate = Date()
    
    @State private var showFilters = false
    
    var body: some View {
        NavigationStack {
            if showFilters {
                VStack {
                    DatePicker("Start", selection: $startDate, in: ...endDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                    ForEach($monitorToggles) { $toggle in
                        Toggle(isOn: $toggle.isSelected) {
                            Text(toggle.name)
                        }
                    }
                }.padding()
            }
            List {
                if(events.isEmpty){
                    Text("No events found for filter")
                } else {
                    ForEach(events){ event in
                        NavigationLink(value: event) {
                            EventsListView(event: event)
                        }
                    }
                }
            }
            .refreshable{fetchMonitorStatus()}
            .navigationTitle("Events")
            .navigationDestination(for: MonitorEvent.self, destination: { event in
                EventDetailView(event: event)
            })
            .toolbar {
                ToolbarItem {
                    Button(action: { withAnimation { showFilters.toggle()}}){
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .onChange(of: startDate, fetchMonitorStatus)
        .onChange(of: endDate, fetchMonitorStatus)
        .onChange(of: monitorToggles, fetchMonitorStatus)
        .onAppear{fetchMonitorStatus()}
    }
    
    func fetchMonitorsHistory() {
       print("Fetching monitor history")
       let dispatchGroup = DispatchGroup()
       var tempHistoryData: [Int: [Status]] = [:]

        for monitor in monitorToggles.filter({$0.isSelected}) {
               dispatchGroup.enter()
               MonitorsService.getMonitorHistory(id: monitor.id, start: startDate, end: endDate) { result in
                   DispatchQueue.main.async {
                       switch result {
                       case .success(let data):
                           tempHistoryData[monitor.id] = data
                       case .failure(let error):
                           print(error)
                       }
                       dispatchGroup.leave()
                   }
               }
           }

           dispatchGroup.notify(queue: .main) {
               self.monitorHistoryData = tempHistoryData
               print("All history data fetched and updated")
               events = []
               for monitor in monitorToggles.filter({$0.isSelected}) {
                   let eventStatuses = monitorHistoryData[monitor.id]!.sorted(by: {$0.dateRecorded < $1.dateRecorded}).map {MonitorEventStatus(status: $0)}
                   if(!eventStatuses.contains(where: {$0.status == false})) { continue }
                   var currentLog: [MonitorEventStatus] = []
                   let firstBadIndex = eventStatuses.firstIndex(where: {$0.status == false})!
                   for event in eventStatuses[firstBadIndex...] {
                       if(currentLog.isEmpty){
                           currentLog.append(event)
                           continue
                       }
                       // false to true
                       if(event.status == true && currentLog.last!.status == false){
                           currentLog.append(event)
                       }
                       // true to false
                       if(event.status == false && currentLog.last!.status == true){
                           if(event.date.timeIntervalSince(currentLog.last!.date) <= 60 * 60){
                               currentLog.append(event)
                           } else {
                               // not within threshold
                               events.append(MonitorEvent(monitor: monitor, log: currentLog))
                               currentLog = []
                               currentLog.append(event)
                           }
                       }
                   }
                   if(!currentLog.isEmpty){
                       events.append(MonitorEvent(monitor: monitor, log: currentLog))
                   }
               }
           }
       }
    
    func fetchMonitorStatus() {
        print("Fetching monitor data")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        MonitorsService.getMonitors { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    monitorData = data
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            for monitor in monitorData {
                if(!monitorToggles.contains { $0.id == monitor.id }){
                    monitorToggles.append(MonitorToggle(id: monitor.id, name: monitor.name, isSelected: true))
                }
            }
            fetchMonitorsHistory()
        }
    }
}

#Preview {
    EventsView(monitorData: [], monitorHistoryData: [:])
}
