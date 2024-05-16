//
//  MonitorsModel.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/16/24.
//

import Foundation
import SwiftUI

class Monitors: ObservableObject {
    @Published var monitorConfigurations: [MonitorStatus]
    @Published var monitorHistoryData: [Int: [Status]]
    @Published var groups: [MonitorGroup]
    
    init() {
        print("Inited view model")
        monitorConfigurations = []
        monitorHistoryData = [:]
        groups = []
        refreshData()
    }
    
    func refreshData(){
        fetchMonitors()
        fetchGroups()
    }
    
    func bindingForMonitor(at index: Int) -> Binding<MonitorStatus> {
        Binding<MonitorStatus>(
            get: { self.monitorConfigurations[index] },
            set: { self.monitorConfigurations[index] = $0 }
        )
    }
    
    func bindingForHistoryData(monitorId: Int) -> Binding<[Status]> {
        Binding<[Status]>(
            get: { self.monitorHistoryData[monitorId]! },
            set: { self.monitorHistoryData[monitorId] = $0 }
        )
    }
    
    func fetchMonitors(){
        print("Fetching monitor data")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        MonitorsService.getMonitorsWithStatus { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.monitorConfigurations = data
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.fetchMonitorsHistory()
        }
    }
    
    func fetchMonitorsHistory(){
        print("Fetching monitor history")
        let dispatchGroup = DispatchGroup()
        var tempHistoryData: [Int: [Status]] = [:]

        for monitor in monitorConfigurations {
            dispatchGroup.enter()
            MonitorsService.getMonitorHistory(id: monitor.id, condensed: true) { result in
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
        }
    }
    
    func fetchGroups(){
        MonitorsService.getMonitorGroups { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.groups = data
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
