//
//  ContentView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/20/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("Ip") var ip: String = ""
    @State var selected = 1
    
    var body: some View {
        MonitorsGeneralView()
//        TabView(selection: $selected) {
//            MonitorsGeneralView().tabItem({
//                Label("Monitors", systemImage: "externaldrive")
//            }).tag(1)
//            SettingsView().tabItem(){
//                Label("Settings", systemImage: "gear")
//            }.tag(2)
//        }.onAppear(){
//            if(ip.isEmpty){
//                selected = 2
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
