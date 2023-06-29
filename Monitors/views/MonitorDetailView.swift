//
//  MonitorDetailView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/29/23.
//

import SwiftUI

struct MonitorDetailView: View {
    let monitor: Monitor
    
    var body: some View {
        if(monitor.type == "minecraft"){
            minecraftView()
        } else {
            webView()
        }
    }
    
    func minecraftView() -> some View {
        VStack {
            Text(monitor.name).font(.title)
            Text(monitor.status ? "Online" : "Offline").foregroundColor(monitor.status ? .green : .red)
            Form {
                if(monitor.online! > 0){
                    Section("Players online"){
                        ForEach(monitor.onlinePlayers!.sorted(by: <), id: \.self){player in
                            Text(player)
                        }
                    }
                }
                Section("General information"){
                    Text("Address: \(monitor.url)")
                    Text("Port: \(String(monitor.port))")
                    Text("Currently online: \(monitor.online!)")
                    Text("Max players: \(monitor.max!)")
                    Text("MOTD: \(monitor.motd!)")
                    Text("version \(monitor.version!)")
                }
            }
        }
    }
    
    func webView() -> some View {
        VStack {
            Text(monitor.name).font(.title)
            Text(monitor.status ? "Online" : "Offline").foregroundColor(monitor.status ? .green : .red)
            Form {
                Section("General Information"){
                    Text("URL: \(monitor.url)")
                    Text("Port: \(String(monitor.port))")
                    Text("\(monitor.type == "api" ? "Health check URL: \(monitor.healthCheckUrl!)" : "Regex: \(monitor.regex!)")")
                }
            }
        }
    }
}

struct MonitorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorDetailView(monitor: Monitor.previewMonitor())
    }
}
