//
//  MonitorsModel.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/16/24.
//

import Foundation
import SwiftUI

class DataOtterModel: ObservableObject {
    @Published var monitorConfigurations: [Monitor]
    @Published var monitorHistoryData: [Int: [Status]]
    @Published var applications: [Application]
    @Published var tags: [Tag]
    @Published var rockStats: [Int64: Int64]
    
    @Published var monitorsLoading: Bool
    @Published var monitorHistoryLoading: Bool
    @Published var applicationLoading: Bool
    @Published var tagsLoading: Bool
    @Published var rockStatsLoading: Bool
    
    var applicationGraphData: [GraphEntry] {
        return applications.flatMap { application in
            monitorHistoryData.filter {(key, value) in
                application.monitorIds.contains(Int64(key))
            }.flatMap { (key, value) in
                return value.compactMap {
                    GraphEntry(name: application.name, taken: $0.dateRecorded, status: $0.status)
                }
            }
        }
    }
    

    var monitorGraphData: [GraphEntry] {
        return []
    }
    
    init(monitorConfigurations: [Monitor], monitorHistoryData: [Int: [Status]], applications: [Application], tags: [Tag], rockStats: [Int64: Int64]) {
        self.monitorConfigurations = monitorConfigurations
        self.monitorHistoryData = monitorHistoryData
        self.applications = applications
        self.tags = tags
        self.rockStats = rockStats
        monitorsLoading = true
        monitorHistoryLoading = false
        applicationLoading = false
        tagsLoading = false
        rockStatsLoading = false
    }
    
    init() {
        print("Inited view model")
        monitorConfigurations = []
        monitorHistoryData = [:]
        applications = []
        tags = []
        rockStats = [:]
        monitorsLoading = true
        monitorHistoryLoading = true
        applicationLoading = true
        tagsLoading = true
        rockStatsLoading = true
        refreshData()
    }
    
    func getMonitorById(_ monitorId: Int) -> Monitor? {
        monitorConfigurations.first(where: {$0.id == monitorId})
    }
    
    func getMonitorHistoryData(monitor: Monitor) -> [Status]{
        return monitorHistoryData[monitor.id] ?? []
    }
    
    /// Fetches monitors and groups from the backend API
    func refreshData(){
        fetchApplications()
        fetchTags()
        fetchMonitors()
        // Create a background queue for polling `monitorsLoading`
        let backgroundQueue = DispatchQueue(label: "monitors.loading.queue", qos: .background)
        
        backgroundQueue.async {
            // Wait asynchronously for `monitorsLoading` to become false
            while self.monitorsLoading {
                usleep(100_000) // Sleep for 100ms to avoid busy-waiting
            }
            
            // Once monitorsLoading is false, proceed with fetching monitor history
            DispatchQueue.main.async {
                self.fetchMonitorsHistory()
            }
        }
    }
    
    /// Get a binding for a monitor at a specific index
    /// - Parameter index: index to get the binding at
    /// - Returns: Binding of a monitor
    func bindingForMonitor(at index: Int) -> Binding<Monitor> {
        Binding<Monitor>(
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
    ///   - applicationId: Applicaiton Id f
    ///  - completion: Completion when the service gets data back
    func createMonitor(monitorData: MonitorData, applicationId: Int64, completion: @escaping (Result<Monitor, Error>) -> Void) {
        MonitorsService.createMonitor(monitorData: monitorData, applicationId: applicationId) { result in
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
    
    
    func createApplication(applicationData: ApplicationCreateData, completion: @escaping (Result<Application, Error>) -> Void) {
        MonitorsService.createApplication(applicationData: applicationData, completion: completion)
    }
    
    /// Update a monitor on the backend API
    /// - Parameters:
    ///   - monitorData: Monitor data to update with
    ///   - completion: Completion when the service gets data back
    func updateMonitor(monitorData: Monitor, completion: @escaping (Result<Monitor, Error>) -> Void) {
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
                self.monitorsLoading = false
                switch result {
                case .success(let data):
                    self.monitorConfigurations = data
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
    }
    
    /// Fetch monitor history from the backend API
    func fetchMonitorsHistory(){
        print("Fetching monitor history")
        let dispatchGroup = DispatchGroup()
        var tempHistoryData: [Int: [Status]] = [:]

        for monitor in monitorConfigurations {
            dispatchGroup.enter()
            MonitorsService.getMonitorHistory(applicationId: monitor.applicationId, id: monitor.id, condensed: true) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        print("Ben")
                        print(data)
                        tempHistoryData[monitor.id] = data
                    case .failure(let error):
                        self.monitorHistoryLoading = false
                        print(error)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.monitorHistoryData = tempHistoryData
            self.monitorHistoryLoading = false
            print("All history data fetched and updated")
        }
    }
    
    func fetchApplications(){
        MonitorsService.getApplicationsWithStatus { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Applications done loading")
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
