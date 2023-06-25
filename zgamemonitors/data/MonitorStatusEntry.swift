//
//  MonitorStatusEntry.swift
//  zgamemonitorsExtension
//
//  Created by Benjamin Shabowski on 6/22/23.
//

import Foundation
import WidgetKit

struct MonitorStatusEntry: TimelineEntry {
    let date: Date
    var up: Int
    var down: Int
    let total: Int
    var downMonitors: [String]
    var upMonitors: [String]
    
    init(date: Date, monitors: [Monitor]) {
        self.date = date
        downMonitors = []
        upMonitors = []
        for monitor in monitors {
            if(monitor.status){ // up
                upMonitors.append(monitor.name)
            } else { // down
                downMonitors.append(monitor.name)
            }
        }
        up = upMonitors.count
        down = downMonitors.count
        total = down + up
    }
}
