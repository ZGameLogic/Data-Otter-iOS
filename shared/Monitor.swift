//
//  Monitor.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/21/23.
//

import Foundation
import WidgetKit
import SwiftUI

struct Monitor: Codable, Comparable {
    
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
    
    var body: some View {
        VStack {
            Text(name).font(.title)
            Text(type).font(.footnote)
            Text(status ? "Online" : "Offline").foregroundColor(status ? .green : .red)
            Spacer()
            Text(url)
            Text("\(String(port))")
            Group {
                switch(type){
                case "minecraft":
                    Text("Max players: \(max!)")
                    Text("Current online: \(online!)")
                    if(!(onlinePlayers ?? []).isEmpty){
                        Text("Online Players")
                        ForEach (onlinePlayers!, id:\.self){Text($0)}
                    }
                    Text("MOTD: \(motd!)")
                    Text("version \(version!)")
                case "api":
                    Text("Health check URL: \(healthCheckUrl!)")
                case "web":
                    Text("Regex: \(regex!)")
                default:
                    Text("none")
                }
            }
            Spacer()
            Spacer()
            Spacer()
        }
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
