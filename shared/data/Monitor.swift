//
//  Monitor.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/21/23.
//

import Foundation
import WidgetKit
import SwiftUI

struct Monitor: Codable, Comparable, Hashable, Identifiable {
    
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
        case name, status, type, url, taken, port, max, online, onlinePlayers, motd, version, regex, healthCheckUrl, id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.status = try container.decode(Bool.self, forKey: .status)
        self.type = try container.decode(String.self, forKey: .type)
        self.taken = try container.decode(Date.self, forKey: .taken)
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
    
    init(name: String, status: Bool, type: String, taken: Date, url: String, port: Int, id: Int, max: Int? = nil, onlinePlayers: [String]? = nil, online: Int? = nil, motd: String? = nil, version: String? = nil, regex: String? = nil, healthCheckUrl: String? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.type = type
        self.taken = taken
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
    let id: Int
    let taken: Date
    
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
        Monitor(name: "test", status: true, type: "minecraft", taken: Date(), url: "zgamelogic.com", port: 25565, id: 0, max: 10, onlinePlayers: ["zabory"], online: 1, motd: "Have fun!", version: "1.19.2", regex: nil, healthCheckUrl: nil),
        Monitor(name: "test 2", status: false, type: "api", taken: Date(), url: "zgamelogic.com", port: 8080, id: 1, max: nil, onlinePlayers: nil, online: nil, motd: nil, version: nil, regex: nil, healthCheckUrl: "health")
        ]
    }
    
    static func previewArrayAllGood() -> [Monitor] {
       [
        Monitor(name: "Minecraft", status: true, type: "minecraft", taken: Date(), url: "zgamelogic.com", port: 25565, id: 0, max: 10, onlinePlayers: ["zabory", "RebaHatesThings"], online: 2, motd: "Have fun!", version: "1.19.2", regex: nil, healthCheckUrl: nil),
        Monitor(name: "test 2", status: true, type: "api", taken: Date(), url: "zgamelogic.com", port: 8080, id: 1, max: nil, onlinePlayers: nil, online: nil, motd: nil, version: nil, regex: nil, healthCheckUrl: "health")
        ]
    }
    
    static func previewMonitor() -> Monitor {
        Monitor(name: "test", status: true, type: "minecraft", taken: Date(), url: "zgamelogic.com", port: 25565, id: 0, max: 10, onlinePlayers: ["zabory"], online: 1, motd: "Have fun!", version: "1.19.2", regex: nil, healthCheckUrl: nil)
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
        print(error)
        throw networkError.invalidData
    }
}

func fetch(id: Int) async throws -> [Monitor] {
    print("Fetching monitor \(id) from API")
    guard let url = URL(string: "http://54.211.139.84:8080/monitors/\(id)") else { throw networkError.inavlidURL }
    
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

func fetchHistory(id: Int) async throws -> [Monitor] {
    print("Fetching monitor \(id) history from API")
    guard let url = URL(string: "http://54.211.139.84:8080/history/\(id)") else { throw networkError.inavlidURL }
    
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