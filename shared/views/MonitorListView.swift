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
                Text(monitor.name).foregroundColor(monitor.status[0].status ? .green : .red)
                Spacer()
            }
            HStack {
                Text(monitor.type)
                if((monitor.status[0].onlinePlayers ?? []).count != 0){
                    Text("Online: \(monitor.status[0].online!)")
                }
                Spacer()
            }.font(.footnote)
        }
    }
}

struct MonitorListView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorListView(monitor: Monitor.previewMonitor())
    }
}
