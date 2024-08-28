//
//  MonitorsModel.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/16/24.
//

import Foundation
import SwiftUI

class DataOtterModel: ObservableObject {
    @Published var monitorConfigurations: [MonitorStatus]
    @Published var monitorHistoryData: [Int: [Status]]
    @Published var applications: [Application]
    @Published var tags: [Tag]
    
    @Published var monitorStatusLoading: Bool
    @Published var monitorHistoryLoading: Bool
    @Published var applicationLoading: Bool
    @Published var tagsLoading: Bool
    
    init(monitorConfigurations: [MonitorStatus], monitorHistoryData: [Int: [Status]], applications: [Application], tags: [Tag]) {
        self.monitorConfigurations = monitorConfigurations
        self.monitorHistoryData = monitorHistoryData
        self.applications = applications
        self.tags = tags
        monitorStatusLoading = true
        monitorHistoryLoading = false
        applicationLoading = false
        tagsLoading = false
    }
    
    init() {
        print("Inited view model")
        monitorConfigurations = []
        monitorHistoryData = [:]
        applications = []
        tags = []
        monitorStatusLoading = true
        monitorHistoryLoading = false
        applicationLoading = true
        tagsLoading = true
        refreshData()
    }
    
    func getMonitorById(_ monitorId: Int) -> MonitorStatus? {
        monitorConfigurations.first(where: {$0.id == monitorId})
    }
    
    func getMonitorHistoryData(monitor: MonitorStatus) -> [Status]{
        return monitorHistoryData[monitor.id] ?? []
    }
    
    /// Fetches monitors and groups from the backend API
    func refreshData(){
        fetchApplications()
        fetchTags()
        fetchMonitors()
    }
    
    /// Get a binding for a monitor at a specific index
    /// - Parameter index: index to get the binding at
    /// - Returns: Binding of a monitor
    func bindingForMonitor(at index: Int) -> Binding<MonitorStatus> {
        Binding<MonitorStatus>(
            get: { self.monitorConfigurations[index] },
            set: { self.monitorConfigurations[index] = $0 }
        )
    }
    
    /// Get a binding for a list of statuses
    /// - Parameter monitorId: monitor id to get the status history for
    /// - Returns: Binding for history data
    func bindingForHistoryData(monitorId: Int) -> Binding<[Status]> {
        Binding<[Status]>(
            get: { self.monitorHistoryData[monitorId]! },
            set: { self.monitorHistoryData[monitorId] = $0 }
        )
    }
    
    /// Delete a monitor on the backend API
    /// - Parameters:
    ///   - monitorId: Monitor ID to delete
    ///   - completion: Completion when the service gets data back
    func deleteMonitor(monitorId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        MonitorsService.deleteMonitor(monitorId: monitorId){ result in
            DispatchGroup().notify(queue: .main) {
                switch(result){
                case .success(_):
                    self.monitorConfigurations.removeAll(where: {$0.id == monitorId})
                    completion(.success(Void()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Create a monitor on the backend API
    /// - Parameters:
    ///   - monitorData: Monitor data to create
    ///   - completion: Completion when the service gets data back
    func createMonitor(monitorData: MonitorData, completion: @escaping (Result<MonitorStatus, Error>) -> Void) {
        MonitorsService.createMonitor(monitorData: monitorData) { result in
            DispatchGroup().notify(queue: .main) {
                switch(result){
                case .success(let data):
                    self.monitorConfigurations.append(data)
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Update a monitor on the backend API
    /// - Parameters:
    ///   - monitorData: Monitor data to update with
    ///   - completion: Completion when the service gets data back
    func updateMonitor(monitorData: MonitorStatus, completion: @escaping (Result<MonitorStatus, Error>) -> Void) {
        MonitorsService.updateMonitor(monitorData: monitorData) { result in
            DispatchGroup().notify(queue: .main) {
                switch(result){
                case .success(let data):
                    self.monitorConfigurations[self.monitorConfigurations.firstIndex(where: {$0.id == monitorData.id})!] = monitorData
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Fetch the monitors from backend API
    func fetchMonitors(){
        print("Fetching monitor data")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        MonitorsService.getMonitorsWithStatus { result in
            DispatchQueue.main.async {
                self.monitorStatusLoading = false
                switch result {
                case .success(let data):
                    self.monitorConfigurations = data
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        
//        dispatchGroup.notify(queue: .main) {
//            self.fetchMonitorsHistory()
//        }
    }
    
    /// Fetch monitor history from the backend API
    func fetchMonitorsHistory(){
        print("Fetching monitor history")
        let dispatchGroup = DispatchGroup()
        var tempHistoryData: [Int: [Status]] = [:]

        for monitor in monitorConfigurations {
            dispatchGroup.enter()
            MonitorsService.getMonitorHistory(id: monitor.id, condensed: true) { result in
                DispatchQueue.main.async {
                    self.monitorHistoryLoading = false
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
    
    func fetchApplications(){
        MonitorsService.getApplicationsWithStatus { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.applications = data
                case .failure(let error):
                    print(error)
                }
                self.applicationLoading = false
            }
        }
    }
    
    func fetchTags(){
        MonitorsService.getTags { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.tags = data
                case .failure(let error):
                    print(error)
                }
                self.tagsLoading = false
            }
        }
    }
}
