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
    var onlinePlayers: Int
    var downMonitors: [Monitor]
    var upMonitors: [Monitor]
    var historyData: [Monitor]
    
    init(date: Date, monitors: [Monitor], historyData: [Monitor]) {
        self.date = date
        self.historyData = historyData
        downMonitors = []
        upMonitors = []
        onlinePlayers = 0
        for monitor in monitors {
            if(monitor.status){ // up
                upMonitors.append(monitor)
                if(monitor.type == "minecraft"){
                    onlinePlayers += monitor.online!
                }
            } else { // down
                downMonitors.append(monitor)
            }
        }
        up = upMonitors.count
        down = downMonitors.count
        total = down + up
    }
    
    func hasOnlinePlayers() -> Bool {
        onlinePlayers > 0
    }
    
    func getOnlinePlayerNames() -> [String] {
        var names: [String] = []
        
        for monitor in upMonitors {
            if(monitor.type == "minecraft"){
                names.append(contentsOf: monitor.onlinePlayers!)
            }
        }
        
        return names.sorted(by: <)
    }
}
