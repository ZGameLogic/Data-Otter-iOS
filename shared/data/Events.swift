//
//  Events.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/25/23.
//

import Foundation


struct Events: Codable, Comparable {
    static func < (lhs: Events, rhs: Events) -> Bool {
        lhs.time < rhs.time
    }
    
    static func == (lhs: Events, rhs: Events) -> Bool {
        lhs.time == rhs.time
    }
    
    
    enum DecodingKeys: String, CodingKey {
        case time, events
    }
    
    let time: Date
    let events: [Event]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let num = try container.decode(UInt64.self, forKey: .time)
        let dateNum = Double(num / 1000)
        self.time = Date(timeIntervalSince1970: dateNum)
        self.events = try container.decode([Event].self, forKey: .events)
    }
    
    struct Event: Codable {
        let monitor: String
        let status: Bool
    }
    
    
}


func fetch(startDate: Date? = nil, endDate: Date? = nil) async throws -> [Events]{
    print("Fetching events from API")
    
    var parameters: [String] = []
    if let startDate {
        parameters.append("startDate=\(UInt64(startDate.timeIntervalSince1970) * 1000)")
    }
    if let endDate {
        parameters.append("endDate=\(UInt64(endDate.timeIntervalSince1970) * 1000)")
    }
    let parameterString = parameters.count > 0 ? "?\(parameters.joined(separator: "&"))" : ""
    guard let url = URL(string: "\(Monitor.BASE_URL)/events\(parameterString)") else { throw networkError.inavlidURL }
    let(data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw networkError.inavlidResponse
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode([Events].self, from: data)
    } catch {
        print(error)
        throw networkError.invalidData
    }
}
