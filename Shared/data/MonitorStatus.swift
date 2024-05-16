//
//  MonitorStatus.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 5/12/24.
//

import Foundation
import SwiftUI
import WidgetKit

struct MonitorStatus: Codable, Identifiable, Hashable {
    let id: Int
    var name: String
    var type: String
    var url: String
    var regex: String
    let status: Status?
    let groups: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case url
        case regex
        case status
        case groups = "group ids"
    }
    
    func getStatusColor() -> Color {
        guard let status = status else {
            return .primary
        }
        return status.status ? .green : .red
    }
    
    mutating func update(data: MonitorData){
        name = data.name
        type = data.type
        url = data.url
        regex = data.regex
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(String.self, forKey: .type)
        self.url = try container.decode(String.self, forKey: .url)
        self.regex = try container.decode(String.self, forKey: .regex)
        self.status = try container.decodeIfPresent(Status.self, forKey: .status)
        self.groups = try container.decode([Int].self, forKey: .groups)
    }
    
    init(id: Int, name: String, type: String, url: String, regex: String, status: Status?, groups: [Int]) {
        self.id = id
        self.name = name
        self.type = type
        self.url = url
        self.regex = regex
        self.status = status
        self.groups = groups
    }
}

struct Status: Codable, Hashable, Identifiable {
    let id: String
    let dateRecorded: Date
    let milliseconds: Int64
    let status: Bool
    let attempts: Int
    let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case dateRecorded = "date recorded"
        case milliseconds
        case status
        case attempts
        case statusCode = "status code"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        self.dateRecorded = dateFormatter.date(from: try container.decode(String.self, forKey: .dateRecorded)) ?? Date()
        self.milliseconds = try container.decode(Int64.self, forKey: .milliseconds)
        self.status = try container.decode(Bool.self, forKey: .status)
        self.attempts = try container.decode(Int.self, forKey: .attempts)
        self.statusCode = try container.decode(Int.self, forKey: .statusCode)
        id = "\(dateRecorded)\(milliseconds)\(status)\(attempts)\(statusCode)"
    }
    
    init(dateRecorded: Date, milliseconds: Int64, status: Bool, attempts: Int, statusCode: Int) {
        self.dateRecorded = dateRecorded
        self.milliseconds = milliseconds
        self.status = status
        self.attempts = attempts
        self.statusCode = statusCode
        id = "\(dateRecorded)\(milliseconds)\(status)\(attempts)\(statusCode)"
    }
}

struct MonitorStatusHistoryEntry: TimelineEntry {
    let date: Date
    let monitors: [MonitorStatus]
    let history: [Int: [Status]]
}

struct MonitorStatusEntry: TimelineEntry {
    let date: Date
    let monitors: [MonitorStatus]
    var downMonitors: [String] { monitors.filter { $0.status?.status == false }.map { $0.name }}
    var upMonitors : [String] { monitors.filter { $0.status?.status == true }.map { $0.name }}
    var up: Int { monitors.filter { $0.status?.status == true }.count }
    var down: Int { monitors.filter { $0.status?.status == false }.count }
    var total: Int { monitors.count }
    
    init(date: Date, monitors: [MonitorStatus]){
        self.date = date
        self.monitors = monitors
    }
}

struct MonitorEvent: Identifiable, Hashable, Equatable {
    
    static func == (lhs: MonitorEvent, rhs: MonitorEvent) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let monitorId: Int
    let name: String
    let log: [MonitorEventStatus]
    
    var eventStatus: Bool {
        if let top = log.sorted(by: { $0.date > $1.date }).first {
            return top.status
        }
        return true
    }
    
    var start: Date {
        if let first = log.sorted(by: { $0.date < $1.date }).first {
            return first.date
        }
        return Date()
    }
    
    var end: Date {
        if let last = log.sorted(by: { $0.date > $1.date }).first {
            return last.date
        }
        return Date()
    }
    
    init(monitor: MonitorToggle, log: [MonitorEventStatus]) {
        self.monitorId = monitor.id
        self.name = monitor.name
        self.log = log
        id = "\(monitorId) \(name) \(log)"
    }
}

struct MonitorEventStatus: Equatable, Hashable, Identifiable {
    let id: String
    var date: Date
    var status: Bool
    
    init(status: Status) {
        self.date = status.dateRecorded
        self.status = status.status
        self.id = "\(status) \(date)"
    }
}

struct MonitorToggle: Identifiable, Equatable {
    let id: Int
    let name: String
    var isSelected: Bool
}

struct MonitorGroup: Identifiable, Codable {
    let id: Int
    let name: String
}
