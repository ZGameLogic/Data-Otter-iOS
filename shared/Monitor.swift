//
//  Monitor.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/21/23.
//

import Foundation
import WidgetKit
import SwiftUI

struct Monitor: Codable, Comparable, Hashable {
    
    static func < (lhs: Monitor, rhs: Monitor) -> Bool {
        if(lhs.type == rhs.type){
            return lhs.name < rhs.name
        } else {
            if(lhs.type == "minecraft") {
                return true
            } else if(rhs.type == "minecraft"){
                return false
            }
            return lhs.type < rhs.type
        }
    }
    
    enum DecodingKeys: String, CodingKey {
        case name, status, type, url, port, max, online, onlinePlayers, motd, version, regex, healthCheckUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.status = try container.decode(Bool.self, forKey: .status)
        self.type = try container.decode(String.self, forKey: .type)
        self.url = try container.decode(String.self, forKey: .url)
        self.port = try container.decode(Int.self, forKey: .port)
        self.max = try container.decodeIfPresent(Int.self, forKey: .max)
        self.onlinePlayers = try container.decodeIfPresent([String].self, forKey: .onlinePlayers)
        self.online = try container.decodeIfPresent(Int.self, forKey: .online)
        self.motd = try container.decodeIfPresent(String.self, forKey: .motd)
        self.version = try container.decodeIfPresent(String.self, forKey: .version)
        self.regex = try container.decodeIfPresent(String.self, forKey: .regex)
        self.healthCheckUrl = try container.decodeIfPresent(String.self, forKey: .healthCheckUrl)
    }
    
    init(name: String, status: Bool, type: String, url: String, port: Int, max: Int? = nil, onlinePlayers: [String]? = nil, online: Int? = nil, motd: String? = nil, version: String? = nil, regex: String? = nil, healthCheckUrl: String? = nil) {
        self.name = name
        self.status = status
        self.type = type
        self.url = url
        self.port = port
        self.max = max
        self.onlinePlayers = onlinePlayers
        self.online = online
        self.motd = motd
        self.version = version
        self.regex = regex
        self.healthCheckUrl = healthCheckUrl
    }
    
    let name: String
    let status: Bool
    let type: String
    let url: String
    let port: Int
    
    // minecraft
    let max: Int?
    let onlinePlayers: [String]?
    let online: Int?
    let motd: String?
    let version: String?
    
    // website
    let regex: String?
    
    // api
    let healthCheckUrl: String?
    
    static func previewArray() -> [Monitor] {
       [
            Monitor(name: "test", status: true, type: "minecraft", url: "zgamelogic.com", port: 25565, max: 10, onlinePlayers: ["zabory"], online: 1, motd: "Have fun!", version: "1.19.2", regex: nil, healthCheckUrl: nil),
            Monitor(name: "test 2", status: false, type: "api", url: "zgamelogic.com", port: 8080, max: nil, onlinePlayers: nil, online: nil, motd: nil, version: nil, regex: nil, healthCheckUrl: "health")
        ]
    }
    
    static func previewMonitor() -> Monitor {
        Monitor(name: "test", status: true, type: "minecraft", url: "zgamelogic.com", port: 25565, max: 10, onlinePlayers: ["zabory"], online: 1, motd: "Have fun!", version: "1.19.2", regex: nil, healthCheckUrl: nil)
    }
}

func fetch() async throws -> [Monitor] {
    print("Fetching monitors from API")
    guard let url = URL(string: "http://54.211.139.84:8080/monitors") else { throw networkError.inavlidURL }
    
    let(data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw networkError.inavlidResponse
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode([Monitor].self, from: data)
    } catch {
        throw networkError.invalidData
    }
    
}

enum networkError: Error {
    case inavlidURL
    case inavlidResponse
    case invalidData
}
