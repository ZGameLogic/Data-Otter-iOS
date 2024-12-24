//
//  MonitorListView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct MonitorListView: View {
    let monitor: Monitor

    var body: some View {
        VStack(alignment: .leading){
            Text(monitor.name).foregroundStyle(monitor.getStatusColor())
            Text(monitor.type).font(.footnote)
        }
    }
}
