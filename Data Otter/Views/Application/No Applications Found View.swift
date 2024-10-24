//
//  NoApplicationsFoundView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 8/9/24.
//

import SwiftUI

struct NoApplicationsFoundView: View {
    var body: some View {
        ContentUnavailableView("No application data available", systemImage: "laptopcomputer", description: Text("Use the + icon to add a new application"))
    }
}

#Preview {
    NoApplicationsFoundView()
}
