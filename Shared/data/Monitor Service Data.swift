//
//  Monitor Service Data.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/9/24.
//

import Foundation
import SwiftUI

struct Rock: Codable, Identifiable {
    let id: Date
    let appId: Int64
    let pebble: String
    
    enum CodingKeys: String, CodingKey {
        case id = "date"
        case appId = "applicaiton id"
        case pebble
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
