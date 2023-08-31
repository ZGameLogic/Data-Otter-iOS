//
//  Events.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/25/23.
//

import Foundation


struct Event: Codable, Comparable, Identifiable {
    enum DecodingKeys: String, CodingKey {
        case monitorId, monitor, entries, startTime, endTime
    }
    let id: String
    let monitorId: Int
    let monitor: String
    let startTime: Date
    let endTime: Date
    let entries: [Entry]
    let currentStatus: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.monitorId = try container.decode(Int.self, forKey: .monitorId)
        self.monitor = try container.decode(String.self, forKey: .monitor)
        self.startTime = convertJavaNumberToDate(javaDate: try container.decode(UInt64.self, forKey: .startTime))
        self.endTime = convertJavaNumberToDate(javaDate: try container.decode(UInt64.self, forKey: .endTime))
        self.entries = try container.decode([Entry].self, forKey: .entries)
        
        id = "\(monitorId)_\(monitor)_\(formatDateId(date: startTime))"
        
        currentStatus = entries[0].status
    }
    
    static func < (lhs: Event, rhs: Event) -> Bool {
        lhs.startTime < rhs.startTime
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.startTime == rhs.startTime
    }
}

struct Entry: Codable, Comparable, Identifiable  {
    
    enum DecodingKeys: String, CodingKey {
        case time, status
    }
    
    let time: Date
    let status: Bool
    let id: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.time = convertJavaNumberToDate(javaDate: try container.decode(UInt64.self, forKey: .time))
        self.status = try container.decode(Bool.self, forKey: .status)
        
        id = "\(formatDateId(date: time)) \(status ? "online" : "offline")"
    }
    
    static func < (lhs: Entry, rhs: Entry) -> Bool {
        lhs.time < rhs.time
    }
}

func getDayDates(events: [Event]) -> [Date] {
    var dates: [Date] = []
    for event in events {
        let trimmedDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: event.startTime))!
        if(!dates.contains(trimmedDate)) {
            dates.append(trimmedDate)
        }
    }
    return dates
}

private func convertJavaNumberToDate(javaDate: UInt64) -> Date {
    let dateNum = Double(javaDate / 1000)
    return Date(timeIntervalSince1970: dateNum)
}

private func formatDateId(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd-yyyy hh:mm a"
    return formatter.string(from: date)
}

func fetch(startDate: Date? = nil, endDate: Date? = nil) async throws -> [Event]{
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
        return try decoder.decode([Event].self, from: data)
    } catch {
        print(error)
        throw networkError.invalidData
    }
}
