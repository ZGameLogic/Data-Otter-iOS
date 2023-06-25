//
//  ContentView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/20/23.
//

import SwiftUI

struct ContentView: View {
    @State var monitors: [Monitor] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(monitors.sorted(), id:\.name){monitor in
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
            }.navigationTitle("Monitors")
                .refreshable {
                    await refresh()
            }
        }
        .padding()
        .task {
            await refresh()
        }
    }
    
    func refresh() async {
        do {
            monitors = try await fetch()
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(monitors: [
            Monitor(name: "Test API", status: false, type: "api", online: nil, onlinePlayers: nil),
            Monitor(name: "Test Minecraft", status: true, type: "minecraft", online: 3, onlinePlayers: ["RebaHatesThings", "zabory", "annaisanerd"])
        ])
    }
}
