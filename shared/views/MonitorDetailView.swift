//
//  MonitorDetailView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/29/23.
//

import SwiftUI

struct MonitorDetailView: View {
    @Binding var monitors: [Monitor]
    let id: Int
    let title: Bool
    
    var body: some View {
        if(title){
            Text(monitors.first(where: {$0.id == self.id})!.name).font(.title)
            Text(monitors.first(where: {$0.id == self.id})!.status ? "Online" : "Offline").foregroundColor(monitors.first(where: {$0.id == self.id})!.status ? .green : .red)
        }
        VStack{
            Form {
                if(!title){
                    Section("Monitor"){
                        Text(monitors.first(where: {$0.id == self.id})!.name).foregroundColor(monitors.first(where: {$0.id == self.id})!.status ? .green : .red)
                    }
                }
                if(monitors.first(where: {$0.id == self.id})!.type == "minecraft"){
                    minecraftView()
                } else {
                    webView()
                }
            }.refreshable {
                await refresh()
            }
        }
    }
    
    func refresh() async {
        do {
            let index = monitors.firstIndex(of: {monitors.first(where: {$0.id == self.id})!}())!
            monitors[index] = try await fetch(id: id)[0]
        } catch networkError.inavlidURL {
            print("u")
        } catch networkError.invalidData {
            print("d")
        } catch networkError.inavlidResponse {
            print("r")
        } catch {
            print("huh")
        }
    }
    
    func minecraftView() -> some View {
        Group {
            if(monitors.first(where: {$0.id == self.id})!.online! > 0){
                Section("Players online"){
                    ForEach(monitors.first(where: {$0.id == self.id})!.onlinePlayers!.sorted(by: <), id: \.self){player in
                        Text(player)
                    }
                }
            }
            Section("General information"){
                Text("Address: \(monitors.first(where: {$0.id == self.id})!.url)")
                Text("Port: \(String(monitors.first(where: {$0.id == self.id})!.port))")
                Text("Currently online: \(monitors.first(where: {$0.id == self.id})!.online!)")
                Text("Max players: \(monitors.first(where: {$0.id == self.id})!.max!)")
                Text("MOTD: \(monitors.first(where: {$0.id == self.id})!.motd!)")
                Text("version \(monitors.first(where: {$0.id == self.id})!.version!)")
            }
        }
    }
    
    func webView() -> some View {
        Group {
            Section("General Information"){
                Text("URL: \(monitors.first(where: {$0.id == self.id})!.url)")
                Text("Port: \(String(monitors.first(where: {$0.id == self.id})!.port))")
                Text("\(monitors.first(where: {$0.id == self.id})!.type == "api" ? "Health check URL: \(monitors.first(where: {$0.id == self.id})!.healthCheckUrl!)" : "Regex: \(monitors.first(where: {$0.id == self.id})!.regex!)")")
            }
        }
    }
}

struct MonitorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorDetailView(monitors: Binding.constant(Monitor.previewArray()), id: 0, title: true)
    }
}
