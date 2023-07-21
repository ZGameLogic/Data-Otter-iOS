//
//  SettingsView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 7/21/23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("Ip") var ip: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("General settings"){
                    TextField("IP Address", text: $ip)
                }
            }.navigationTitle("Data Otter Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
