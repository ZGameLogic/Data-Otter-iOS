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
    @Published var rockStats: [String: Int64]
    @Published var agents: [Agent]
    @Published var agentStatusHistory: [Int64: [AgentStatus]]
    
    @Published var monitorsLoading: Bool
    @Published var monitorHistoryLoading: Bool
    @Published var applicationLoading: Bool
    @Published var tagsLoading: Bool
    @Published var rockStatsLoading: Bool
    @Published var agentsLoading: Bool
    
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
    
    init(monitorConfigurations: [Monitor], monitorHistoryData: [Int: [Status]], applications: [Application], tags: [Tag], rockStats: [String: Int64], agents: [Agent], agentStatusHistory: [Int64: [AgentStatus]]) {
        self.monitorConfigurations = monitorConfigurations
        self.monitorHistoryData = monitorHistoryData
        self.applications = applications
        self.tags = tags
        self.rockStats = rockStats
        self.agents = agents
        self.agentStatusHistory = agentStatusHistory
        monitorsLoading = true
        monitorHistoryLoading = false
        applicationLoading = false
        tagsLoading = false
        rockStatsLoading = false
        agentsLoading = false
    }
    
    init() {
        monitorConfigurations = []
        monitorHistoryData = [:]
        applications = []
        tags = []
        rockStats = [:]
        agents = []
        agentStatusHistory = [:]
        monitorsLoading = true
        monitorHistoryLoading = true
        applicationLoading = true
        tagsLoading = true
        rockStatsLoading = true
        agentsLoading = true
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
        fetchAgents()
        fetchRockStats()

        let backgroundQueue = DispatchQueue(label: "monitors.loading.queue", qos: .background)
        backgroundQueue.async {
            while self.monitorsLoading {
                usleep(100_000)
            }
            DispatchQueue.main.async {
                self.fetchMonitorsHistory()
            }
        }
        
        let backgroundAgentQueue = DispatchQueue(label: "agents.loading.queue", qos: .background)
        backgroundAgentQueue.async {
            while self.agentsLoading {
                usleep(100_000)
            }
            DispatchQueue.main.async {
                self.fetchAgentHistory()
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
    
    func fetchAgents(){
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        MonitorsService.getAgentsWithStatus { result in
            DispatchQueue.main.async {
                self.agentsLoading = false
                switch result {
                case .success(let data):
                    self.agents = data
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
    }
    
    func fetchRockStats(){
        MonitorsService.getRockStats { result in
            DispatchQueue.main.async {
                self.rockStatsLoading = false
                switch result {
                case .success(let data):
                    self.rockStats = data
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func fetchAgentHistory(){
        let dispatchGroup = DispatchGroup()
        dispatchGroup.notify(queue: .main) {
            self.agentStatusHistory = [:]
        }
        for agent in agents {
            dispatchGroup.enter()
            MonitorsService.getAgentHistory(agentId: agent.id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.agentStatusHistory[agent.id] = data
                    case .failure(let error):
                        print(error)
                    }
                    dispatchGroup.leave()
                }
            }
        }
    }
    
    /// Fetch monitor history from the backend API
    func fetchMonitorsHistory(){
        let dispatchGroup = DispatchGroup()
        var tempHistoryData: [Int: [Status]] = [:]

        for monitor in monitorConfigurations {
            dispatchGroup.enter()
            MonitorsService.getMonitorHistory(applicationId: monitor.applicationId, id: monitor.id, condensed: true) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
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
        }
    }
    
    func fetchApplications(){
        print("Application start loading")
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
    
    func getAgentStatusHistory(agentId: Int64, stat: AgentStat) -> [SmallStat] {
        if let history = agentStatusHistory[agentId] {
            switch(stat) {
            case .RAM:
                return history.filter { $0.status }.map { SmallStat(date: $0.date, value: $0.memoryUsage) }
            case .DISK:
                return history.filter { $0.status }.map { SmallStat(date: $0.date, value: $0.diskUsage) }
            case .CPU:
                return history.filter { $0.status }.map { SmallStat(date: $0.date, value: $0.cpuUsage) }
            case .STATUS:
                return history.map { SmallStat(date: $0.date, value: $0.status ? 100 : 0)}
            }
        }
        
        return []
    }
}
