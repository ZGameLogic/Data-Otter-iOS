//
//  MonitorStatus.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 5/12/24.
//

import Foundation
import SwiftUI

struct MonitorStatus: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let type: String
    let url: String
    let regex: String
    let status: Status?
    
    
    func getStatusColor() -> Color {
        guard let status = status else {
            return .primary
        }
        return status.status ? .green : .red
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(String.self, forKey: .type)
        self.url = try container.decode(String.self, forKey: .url)
        self.regex = try container.decode(String.self, forKey: .regex)
        self.status = try container.decodeIfPresent(Status.self, forKey: .status)
    }
    
    init(id: Int, name: String, type: String, url: String, regex: String, status: Status?) {
        self.id = id
        self.name = name
        self.type = type
        self.url = url
        self.regex = regex
        self.status = status
    }
}

struct Status: Codable, Hashable {
    let dateRecorded: Date
    let milliseconds: Int64
    let status: Bool
    let attempts: Int
    let statusCode: Int
    
    enum CodingKeys: String, CodingKey {
        case dateRecorded = "date recorded"
        case milliseconds
        case status
        case attempts
        case statusCode = "status code"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-dd-MM HH:mm:ss"
        self.dateRecorded = dateFormatter.date(from: try container.decode(String.self, forKey: .dateRecorded)) ?? Date()
        self.milliseconds = try container.decode(Int64.self, forKey: .milliseconds)
        self.status = try container.decode(Bool.self, forKey: .status)
        self.attempts = try container.decode(Int.self, forKey: .attempts)
        self.statusCode = try container.decode(Int.self, forKey: .statusCode)
    }
    
    init(dateRecorded: Date, milliseconds: Int64, status: Bool, attempts: Int, statusCode: Int) {
        self.dateRecorded = dateRecorded
        self.milliseconds = milliseconds
        self.status = status
        self.attempts = attempts
        self.statusCode = statusCode
    }
}
