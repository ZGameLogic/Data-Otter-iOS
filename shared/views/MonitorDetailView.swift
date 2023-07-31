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
        VStack{
            if(title){
                Text(monitor().name).font(.title)
                Text(monitor().status[0].status ? "Online" : "Offline").foregroundColor(monitor().status[0].status ? .green : .red)
            }
            Form {
                if(!title){
                    Section("Monitor"){
                        Text(monitor().name).foregroundColor(monitor().status[0].status ? .green : .red)
                    }
                }
                if(monitor().type == "minecraft"){
                    minecraftView()
                } else {
                    webView()
                }
                if(!monitor().status.isEmpty){
                    Section("History"){
                        HistoryGraphView(history: monitor().convertForGraph(), extended: true)
                    }
                }
            }.refreshable {
                await refresh()
            }.onAppear(){
                Task {
                    await refresh()
                }
            }
        }
    }
    
    func refresh() async {
        do {
            let index = monitors.firstIndex(of: {monitor()}())!
            monitors[index] = try await fetchExtendedHistory(id: id)[0]
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
            if(monitor().playersOnline()! > 0){
                Section("Players online"){
                    ForEach(monitor().onlinePlayers()!.sorted(by: <), id: \.self){player in
                        Text(player)
                    }
                }
            }
            Section("General information"){
                Text("Address: \(monitor().url)")
                Text("Port: \(String(monitor().port))")
                Text("Currently online: \(monitor().status[0].online ?? 0)")
                Text("Max players: \(monitor().status[0].max ?? 0)")
                Text("MOTD: \(monitor().status[0].motd ?? "")")
                Text("Version: \(monitor().status[0].version ?? "")")
            }
            Section("Player count"){
                PlayerHistoryGraphView(history: monitor().convertForGraph(), extended: true)
            }
        }
    }
    
    func webView() -> some View {
        Group {
            Section("General Information"){
                Text("URL: \(monitor().url)")
                Text("Port: \(String(monitor().port))")
                Text("\(monitor().type == "api" ? "Health check URL: \(monitor().healthCheckUrl!)" : "Regex: \(monitor().regex!)")")
            }
        }
    }
    
    func monitor() -> Monitor {
        monitors.first(where: {$0.id == self.id})!
    }
}

struct MonitorDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MonitorDetailView(monitors: Binding.constant(Monitor.previewArray()), id: 0, title: true)
    }
}
