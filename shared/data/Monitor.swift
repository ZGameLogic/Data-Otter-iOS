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
    
    static let BASE_URL = "http://54.211.139.84:8080"
    // static let BASE_URL = "http://localhost:8080"
    
    enum DecodingKeys: String, CodingKey {
        case name, status, type, url, port, regex, healthCheckUrl, id
    }
    
    // base
    let name: String
    let type: String
    let url: String
    let port: Int
    let id: Int
    let status: [Status]
    
    // website
    let regex: String?
    
    // api
    let healthCheckUrl: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.status = try container.decode([Status].self, forKey: .status)
        self.type = try container.decode(String.self, forKey: .type)
        self.url = try container.decode(String.self, forKey: .url)
        self.port = try container.decode(Int.self, forKey: .port)
        self.regex = try container.decodeIfPresent(String.self, forKey: .regex)
        self.healthCheckUrl = try container.decodeIfPresent(String.self, forKey: .healthCheckUrl)
    }
    
    init(name: String, type: String, url: String, port: Int, id: Int, status: [Status], regex: String? = nil, healthCheckUrl: String? = nil) {
        self.name = name
        self.type = type
        self.url = url
        self.port = port
        self.id = id
        self.status = status
        self.regex = regex
        self.healthCheckUrl = healthCheckUrl
    }
    
    func convertForGraph() -> [GraphEntry] {
        var entries: [GraphEntry] = []
        for stat in status {
            entries.append(GraphEntry(status: stat, monitor: self))
        }
        return entries
    }
    
    func playersOnline() -> Int? {
        status[0].online
    }
    
    func onlinePlayers() -> [String]? {
        status[0].onlinePlayers
    }
    
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
    
    static func previewArray() -> [Monitor] {
        var monitors: [Monitor] = []
        for _ in 1...3 {
            monitors.append(randomMonitor())
        }
        return monitors
    }
    
    static func previewArrayAllGood() -> [Monitor] {
        var monitors: [Monitor] = []
        for _ in 1...3 {
            monitors.append(randomMonitor(allGood: true))
        }
        return monitors
    }
    
    static func previewMonitor() -> Monitor {
        randomMonitor()
    }
    
    static func previewHistoryData() -> [Monitor] {
        var monitors: [Monitor] = []
        for _ in 1...3 {
            monitors.append(randomMonitor(history: true))
        }
        return monitors
    }
    
    static func convertToGraph(monitors: [Monitor]) -> [GraphEntry] {
        var entries: [GraphEntry] = []
        for monitor in monitors {
            for entry in monitor.convertForGraph() {
                entries.append(entry)
            }
        }
        return entries
    }
    
    static func randomMonitor(allGood: Bool = false, history: Bool = false) -> Monitor {
        let names = ["ZGameLogic", "API", "Web", "Bamboo", "DataDog", "Charlie", "Monster"]
        let types = ["web", "api", "minecraft"]
        let urls = ["zgamelogic.com"]
        let ports = [8080, 443, 25565, 21]
        let type = types.randomElement()!
        return Monitor(name: names.randomElement()!, type: type, url: urls.randomElement()!, port: ports.randomElement()!, id: Int.random(in: 0...100), status: randomStatus(type: type))
    }
    
    static func randomStatus(allGood: Bool = false, history: Bool = false, type: String) -> [Status] {
        var stati: [Status] = []
        let count = history ? Int.random(in: 5...15) : 1
        for _ in 0...count {
            let taken = Date()
            let status = allGood || [true, false].randomElement()!
            let completedInMilliseconds = [123, 124, 12, 13, 45].randomElement()!
            
            var stat = Status(taken: taken, status: status, completedInMilliseconds: completedInMilliseconds)
           
            
            switch type{
            case "minecraft":
                // minecraft
                let max = [20, 40, 60].randomElement()!
                let onlinePlayers = ["zabory"]
                let online = 1
                let motd = "Booty"
                let version = "1.12.2"
                
                stat = Status(taken: taken, status: status, completedInMilliseconds: completedInMilliseconds, max: max, onlinePlayers: onlinePlayers, online: online, motd: motd, version: version)
                break
            default:
                break
            }
            stati.append(stat)
        }
        return stati
    }
}



func fetch() async throws -> [Monitor] {
    print("Fetching monitors from API")
    guard let url = URL(string: "\(Monitor.BASE_URL)/monitors") else { throw networkError.inavlidURL }
    
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
    guard let url = URL(string: "\(Monitor.BASE_URL)/monitors?id=\(id)") else { throw networkError.inavlidURL }
    
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

func fetchExtendedHistory() async throws -> [Monitor] {
    print("Fetching extended monitor history from API")
    guard let url = URL(string: "\(Monitor.BASE_URL)/monitors?history=true&extended=true") else { throw networkError.inavlidURL }
    
    let(data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw networkError.inavlidResponse
    }
    
    do {
        let decoder = JSONDecoder()
        let data = try decoder.decode([Monitor].self, from: data)
        return data
    } catch {
        print(error)
        throw networkError.invalidData
    }
}

func fetchExtendedHistory(id: Int) async throws -> [Monitor] {
    print("Fetching extended monitor \(id) history from API")
    guard let url = URL(string: "\(Monitor.BASE_URL)/monitors?id=\(id)&history=true&extended=true") else { throw networkError.inavlidURL }
    
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


func fetchHistory() async throws -> [Monitor] {
    print("Fetching monitor history from API")
    guard let url = URL(string: "\(Monitor.BASE_URL)/monitors?history=true") else { throw networkError.inavlidURL }
    
    let(data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw networkError.inavlidResponse
    }
    
    do {
        let decoder = JSONDecoder()
        let data = try decoder.decode([Monitor].self, from: data)
        return data
    } catch {
        print(error)
        throw networkError.invalidData
    }
}

func fetchHistory(id: Int) async throws -> [Monitor] {
    print("Fetching monitor \(id) history from API")
    guard let url = URL(string: "\(Monitor.BASE_URL)/monitors?id=\(id)&history=true") else { throw networkError.inavlidURL }
    
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

struct Status: Codable, Hashable {
    
    enum DecodingKeys: String, CodingKey {
        case taken, max, online, onlinePlayers, motd, version, status, completedInMilliseconds
    }
    
    let taken: Date
    let status: Bool
    let completedInMilliseconds: Int
    
    // minecraft
    let max: Int?
    let onlinePlayers: [String]?
    let online: Int?
    let motd: String?
    let version: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decodeIfPresent(UInt64.self, forKey: .taken)
        let dateNum = Double((num ?? 1000)/1000)
        self.taken = Date(timeIntervalSince1970: dateNum)
        self.max = try container.decodeIfPresent(Int.self, forKey: .max)
        self.onlinePlayers = try container.decodeIfPresent([String].self, forKey: .onlinePlayers)
        self.online = try container.decodeIfPresent(Int.self, forKey: .online)
        self.motd = try container.decodeIfPresent(String.self, forKey: .motd)
        self.version = try container.decodeIfPresent(String.self, forKey: .version)
        self.status = try container.decode(Bool.self, forKey: .status)
        self.completedInMilliseconds = try container.decode(Int.self, forKey: .completedInMilliseconds)
    }
    
    init(taken: Date, status: Bool, completedInMilliseconds: Int, max: Int? = nil, onlinePlayers: [String]? = nil, online: Int? = nil, motd: String? = nil, version: String? = nil) {
        self.taken = taken
        self.status = status
        self.completedInMilliseconds = completedInMilliseconds
        self.max = max
        self.onlinePlayers = onlinePlayers
        self.online = online
        self.motd = motd
        self.version = version
    }
    
}

struct GraphEntry: Identifiable, Comparable {
    static func < (lhs: GraphEntry, rhs: GraphEntry) -> Bool {
        lhs.taken < rhs.taken
    }
    
    var id: String
    
    let name: String
    let taken: Date
    let status: Bool
    let completedInMilliseconds: Int
    
    // minecraft
    let max: Int?
    let onlinePlayers: [String]?
    let online: Int?
    let motd: String?
    let version: String?
    
    init(status: Status, monitor: Monitor){
        name = monitor.name
        id = name
        taken = status.taken
        self.status = status.status
        completedInMilliseconds = status.completedInMilliseconds
        
        max = status.max
        onlinePlayers = status.onlinePlayers
        online = status.online
        motd = status.motd
        version = status.version
    }
}

enum networkError: Error {
    case inavlidURL
    case inavlidResponse
    case invalidData
}
