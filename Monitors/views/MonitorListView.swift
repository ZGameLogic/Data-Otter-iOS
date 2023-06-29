//
//  MonitorListView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/29/23.
//

import SwiftUI

struct MonitorListView: View {
    let monitor: Monitor
    
    var body: some View {
        VStack {
            HStack {
                Text(monitor.name).foregroundColor(monitor.status ? .green : .red)
                Spacer()
            }
            HStack {
                Text(monitor.type).font(.footnote)
                Spacer()
            }
            if(monitor.type == "minecraft" && (monitor.onlinePlayers ?? []).count != 0){
                HStack {
                    Text("Online: \(monitor.online!)")
                    Spacer()
                }
                ForEach((monitor.onlinePlayers ?? []).sorted(by: <), id:\.self){player in
                    HStack {
                        Text("\t \(player)")
                        Spacer()
                    }
                }
            }
        }
    }
}

struct MonitorListView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorListView(monitor: Monitor.previewMonitor())
    }
}
