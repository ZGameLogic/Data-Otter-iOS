//
//  Monitor.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/21/23.
//

import Foundation

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
        case name, status, type, online, onlinePlayers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.status = try container.decode(Bool.self, forKey: .status)
        self.type = try container.decode(String.self, forKey: .type)
        self.online = try container.decodeIfPresent(Int.self, forKey: .online)
        self.onlinePlayers = try container.decodeIfPresent([String].self, forKey: .onlinePlayers)
    }
    
    let name: String
    let status: Bool
    let type: String
    let online: Int?
    let onlinePlayers: [String]?
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
