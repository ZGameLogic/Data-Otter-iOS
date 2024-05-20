//
//  GroupListView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/19/24.
//

import SwiftUI

struct GroupListView: View {
    let name: String
    let count: Int
    let status: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(name).foregroundStyle(status ? .green : .red)
            Text("Monitors: \(count)")
        }
    }
}
