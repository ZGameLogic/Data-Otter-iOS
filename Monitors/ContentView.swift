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
                            Text(monitor.status ? "🟩" : "🟥")
                            Text(monitor.name)
                            Spacer()
                        }
                        HStack {
                            Text("\t \(monitor.type)").font(.footnote)
                            Spacer()
                        }
                        if(monitor.type == "minecraft"){
                            HStack {
                                Text("Online: \(monitor.online!)")
                                Spacer()
                            }
                            ForEach(monitor.onlinePlayers ?? [], id:\.self){player in
                                Text(player)
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
        ContentView()
    }
}
