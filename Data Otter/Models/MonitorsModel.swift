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
    @Published var groups: [MonitorGroup]
    
    init() {
        print("Inited view model")
        monitorConfigurations = []
        monitorHistoryData = [:]
        groups = []
        refreshData()
    }
    
    func getMonitorById(_ monitorId: Int) -> MonitorStatus? {
        monitorConfigurations.first(where: {$0.id == monitorId})
    }
    
    func getMonitorHistoryData(monitor: MonitorStatus) -> [Status]{
        return monitorHistoryData[monitor.id] ?? []
    }
    
    /// Get an array of groups coorsponding to this monitor
    /// - Parameter monitor: Monitor to get the group IDs from
    /// - Returns: Array of groups
    func getGroupsInMonitor(monitor: MonitorStatus) -> [MonitorGroup] { getGroupsInMonitor(monitorId: monitor.id) }
    
    /// Get an array of groups coorsponding to this monitor
    /// - Parameter monitorId: Monitor ID to get the group IDs from
    /// - Returns: Array of groups
    func getGroupsInMonitor(monitorId: Int) -> [MonitorGroup] {
        groups.filter{ group in
            group.monitors.contains { groupMonitorId in
                    groupMonitorId == monitorId
            }
        }
    }
    
    /// Get an array of monitors coorsponding to this group
    /// - Parameter group: Group to get the monitor IDs from
    /// - Returns: Array of monitors
    func getMonitorsInGroup(group: MonitorGroup) -> [MonitorStatus]{ getMonitorsInGroup(groupId: group.id) }

    /// Get an array of monitors coorsponding to this group
    /// - Parameter groupId: Group to get the monitor IDs from
    /// - Returns: Array of monitors
    func getMonitorsInGroup(groupId: Int) -> [MonitorStatus]{
        monitorConfigurations.filter{ monitor in
            monitor.groups.contains{ monitorGroupId in
                monitorGroupId == groupId
            }
        }
    }
    
    /// Fetches monitors and groups from the backend API
    func refreshData(){
        fetchMonitors()
        fetchGroups()
    }
    
    /// Get a binding for a group at a specific index
    /// - Parameter index: index to get the binding at
    /// - Returns: Binding of a group
    func bindingForGroup(at index: Int) -> Binding<MonitorGroup> {
        Binding<MonitorGroup>(
            get: { self.groups[index] },
            set: { self.groups[index] = $0 }
        )
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
    
    /// Deletes a group from the backend API
    /// - Parameters:
    ///   - groupId: Group ID to delete
    ///   - completion: Completion to run when data gets back
    func deleteGroup(groupId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        MonitorsService.deleteGroup(groupId: groupId) { result in
            DispatchGroup().notify(queue: .main) {
                switch(result){
                case .success():
                    self.groups.removeAll(where: {$0.id == groupId})
                    for monitor in (self.monitorConfigurations.filter{monitor in
                        monitor.groups.contains(groupId)
                    }){
                        if let monitorIndex = self.monitorConfigurations.firstIndex(where: {$0.id == monitor.id}){
                            self.monitorConfigurations[monitorIndex].groups.removeAll(where: {$0 == groupId})
                        }
                    }
                    completion(.success(Void()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Adds a monitor to a group
    /// - Parameters:
    ///   - monitorId: Monitor ID to add to the group
    ///   - groupId: Group ID to add the monitor ID to
    ///   - completion: Completion to run when the data gets back
    func addMonitorToGroup(monitorId: Int, groupId: Int, completion: @escaping (Result<MonitorGroup, Error>) -> Void) {
        MonitorsService.addMonitorToGroup(monitorId: monitorId, groupId: groupId) { result in
            DispatchGroup().notify(queue: .main) {
                switch(result){
                case .success(let data):
                    self.groups[self.groups.firstIndex(where: {$0.id == groupId})!].monitors.append(monitorId)
                    self.monitorConfigurations[self.monitorConfigurations.firstIndex(where: {$0.id == monitorId})!].groups.append(groupId)
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Removes a monitor from a group
    /// - Parameters:
    ///   - monitorId: Monitor ID to remove from the group
    ///   - groupId: Group ID to remove the monitor ID from
    ///   - completion: Completion ot run when the data gets back
    func removeMonitorFromGroup(monitorId: Int, groupId: Int, completion: @escaping (Result<MonitorGroup, Error>) -> Void) {
        MonitorsService.removeMonitorFromGroup(monitorId: monitorId, groupId: groupId) { result in
            DispatchGroup().notify(queue: .main) {
                switch(result){
                case .success(let data):
                    self.groups[self.groups.firstIndex(where: {$0.id == groupId})!].monitors.removeAll(where: {$0 == monitorId})
                    self.monitorConfigurations[self.monitorConfigurations.firstIndex(where: {$0.id == monitorId})!].groups.removeAll(where: {$0 == groupId})
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Create a group on the backend API
    /// - Parameters:
    ///   - group: Group to be created
    ///   - completion: Completion code to run when the data gets back
    func createGroup(group: MonitorGroup, completion: @escaping (Result<MonitorGroup, Error>) -> Void) {
        MonitorsService.createGroup(groupConfiguration: group) { result in
            DispatchGroup().notify(queue: .main) {
                switch(result){
                case .success(let data):
                    self.groups.append(data)
                    for monitor in (self.monitorConfigurations.filter{monitor in
                        data.monitors.contains(where: {$0 == monitor.id})
                    }){
                        if let monitorIndex = self.monitorConfigurations.firstIndex(where: {$0.id == monitor.id}){
                            self.monitorConfigurations[monitorIndex].groups.append(data.id)
                        }
                    }
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createGroup(name: String, completion: @escaping (Result<MonitorGroup, Error>) -> Void) {
        print(name)
        MonitorsService.createGroup(name: name) { result in
            DispatchGroup().notify(queue: .main) {
                switch(result){
                case .success(let data):
                    print("Result Data \(data)")
                    self.groups.append(data)
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
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
    
    /// Fetch monitor history from the backend API
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
    
    /// Fetch the groups from the backend API
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
