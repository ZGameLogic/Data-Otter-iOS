//
//  Monitor Service Data.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/9/24.
//

import Foundation
import SwiftUI

struct Rock: Codable, Identifiable, Equatable {
    static func == (lhs: Rock, rhs: Rock) -> Bool {
        return lhs.id == rhs.id && lhs.appId == rhs.appId
    }
    
    let id: Date
    let appId: Int64
    let pebble: Pebble
    
    enum CodingKeys: String, CodingKey {
        case id = "date"
        case appId = "application id"
        case pebble
    }
    
    enum Pebble: Codable {
        case string(String)
        case dictionary([String: Any])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            // Try decoding as a String
            if let stringValue = try? container.decode(String.self) {
                self = .string(stringValue)
            }
            // Try decoding as a dictionary
            else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
                self = .dictionary(dictionaryValue.mapValues { $0.value })
            }
            // Throw an error if neither works
            else {
                throw DecodingError.typeMismatch(
                    Pebble.self,
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Expected String or Dictionary"
                    )
                )
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let value):
                try container.encode(value)
            case .dictionary(let value):
                try container.encode(value.mapValues { AnyCodable($0) })
            }
        }
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        self.id = dateFormatter.date(from: try container.decode(String.self, forKey: .id)) ?? Date()
        self.appId = try container.decode(Int64.self, forKey: .appId)
        self.pebble = try container.decode(Pebble.self, forKey: .pebble)
    }
}

struct AnyCodable: Codable {
    let value: Any?
    
    init(_ value: Any?) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = nil
        } else if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            self.value = dictionaryValue.mapValues { $0.value }
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            self.value = arrayValue.map { $0.value }
        } else {
            throw DecodingError.typeMismatch(
                AnyCodable.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case nil:
            try container.encodeNil()
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let dictionaryValue as [String: Any]:
            try container.encode(dictionaryValue.mapValues { AnyCodable($0) })
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value as Any,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }
}

struct Application: Codable, Identifiable, Hashable {
    let id: Int64
    let name: String
    let description: String?
    let monitorIds: [Int64]
    let tags: [String]
    let status: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case monitorIds = "monitor ids"
        case tags
        case status
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.monitorIds = try container.decode([Int64].self, forKey: .monitorIds)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.status = try container.decodeIfPresent(Bool.self, forKey: .status)
    }
    
    init(id: Int64, name: String, description: String, monitorIds: [Int64], tags: [String], status: Bool?) {
        self.id = id
        self.name = name
        self.description = description
        self.monitorIds = monitorIds
        self.tags = tags
        self.status = status
    }
    
    var statusColor: Color {
        if let status = status {
            return status ? Color("UpStatusColor") : Color("DownStatusColor")
        } else {
            return Color.primary
        }
    }
}

struct Tag: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let description: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

struct ApplicationCreateData: Encodable {
    let name: String
    let description: String?
    let tags: [Tag]
    
    enum CodingKeys: CodingKey {
        case name
        case description
        case tags
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(tags, forKey: .tags)
    }
}

struct Agent: Codable, Identifiable {
    let id: Int64
    let name: String
    let os: String
    let status: AgentStatus?
}

struct AgentStatus: Codable {
    let date: Date
    let memoryUsage: Int64
    let cpuUsage: Int64
    let diskUsage: Int64
    let agentVersion: String
    let status: Bool
    
    enum CodingKeys: String, CodingKey {
        case date
        case memoryUsage = "memory usage"
        case cpuUsage = "cpu usage"
        case diskUsage = "disk usage"
        case agentVersion = "agent version"
        case status
    }
    
    init(date: Date, memoryUsage: Int64, cpuUsage: Int64, diskUsage: Int64, agentVersion: String) {
        self.date = date
        self.memoryUsage = memoryUsage
        self.cpuUsage = cpuUsage
        self.diskUsage = diskUsage
        self.agentVersion = agentVersion
        self.status = true
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        self.date = dateFormatter.date(from: try container.decode(String.self, forKey: .date)) ?? Date()
        self.memoryUsage = try container.decode(Int64.self, forKey: .memoryUsage)
        self.cpuUsage = try container.decode(Int64.self, forKey: .cpuUsage)
        self.diskUsage = try container.decode(Int64.self, forKey: .diskUsage)
        self.agentVersion = try container.decode(String.self, forKey: .agentVersion)
        self.status = try container.decodeIfPresent(Bool.self, forKey: .status) ?? true
    }
}

enum AgentStat {
    case RAM
    case DISK
    case CPU
    case STATUS
}
