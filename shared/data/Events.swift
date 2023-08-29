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
    
    
}

struct Event: Codable {
    let monitor: String
    let status: Bool
}

struct GroupedEvent: Identifiable {
    let id: String
    let monitor: String
    let status: Bool
    let time: Date
    
    init(event: Event, time: Date) {
        self.monitor = event.monitor
        self.status = event.status
        self.time = time
        self.id = "id: \(monitor) \(formatDateDay(date: time)) \(status)"
    }
}

func groupByDate(events: [Events]) -> [String: [GroupedEvent]]{
    var grouped: [String : [GroupedEvent]] = [:]
    
    for eventGroup in events {
        let date = formatDateDay(date: eventGroup.time)
        let groupedData = convertEventToGrouped(events: eventGroup)
        if(grouped[date] != nil){
            grouped[date]?.append(contentsOf: convertEventToGrouped(events: eventGroup))
        } else {
            grouped[date] = convertEventToGrouped(events: eventGroup)
        }
    }
    
    return grouped
}

private func convertEventToGrouped(events: Events) -> [GroupedEvent] {
    var groupedEvents: [GroupedEvent] = []
    for event in events.events {
        groupedEvents.append(GroupedEvent(event: event, time: events.time))
    }
    return groupedEvents
}

private func formatDateDay(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yyyy"
    return formatter.string(from: date)
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
