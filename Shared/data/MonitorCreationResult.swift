//
//  MonitorCreationResult.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import Foundation

struct MonitorCreationResult: Codable {
    let milliseconds: Int64
    let status: Bool
    let attempts: Int
    let statusCode: Int
}
