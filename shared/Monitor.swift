//
//  Monitor.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/21/23.
//

import Foundation
import WidgetKit

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
