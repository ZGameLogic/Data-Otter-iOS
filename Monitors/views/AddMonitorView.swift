//
//  AddMonitorView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 6/27/23.
//

import SwiftUI

struct AddMonitorView: View {
    @State var tested = false
    @State var succcess = false
    @Binding var showing: Bool
    
    @State var monitorType = "api"
    
    @State var monitorName = ""
    @State var url = ""
    @State var port = ""
    @State var healthCheck = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    TextField("Monitor name", text: $monitorName)
                    Picker(selection: $monitorType, label: Text("Monitor type")) {
                        Text("api").tag("api")
                        Text("web").tag("web")
                        Text("minecraft").tag("minecraft")
                    }.pickerStyle(.segmented)
                }
                Section(monitorType) {
                    TextField("URL", text: $url).keyboardType(.URL)
                    TextField("Port", text: $port).keyboardType(.numberPad)
                    
                    if(monitorType == "api" || monitorType == "web"){
                        TextField("Health check \(monitorType == "api" ? "endpoint" : "text")", text: $healthCheck)
                    }
                }
            }.navigationTitle("New Monitor")
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button(tested ? "Submit" : "Test") {
                        if(!tested){
                            Task {
                                await testMonitor()
                            }
                        } else {
                            Task {
                                await submitMonitor()
                            }
                        }
                    }.foregroundColor(tested ? succcess ? .green : .red : .purple)
                }
                ToolbarItemGroup(placement: .navigationBarLeading){
                    Button("Cancel"){
                        showing = false
                    }.foregroundColor(.red)
                }
            }
        }
    }
    
    func getMonitorFromUI() -> Monitor? {
        switch(monitorType){
        case "minecraft":
            return Monitor(name: monitorName, status: false, type: monitorType, taken: Date(), url: self.url, port: Int(port)!, id: 0)
        case "api":
            return Monitor(name: monitorName, status: false, type: monitorType, taken: Date(), url: self.url, port: Int(port)!, id: 0, healthCheckUrl: healthCheck)
        case "web":
            return Monitor(name: monitorName, status: false, type: monitorType, taken: Date(), url: self.url, port: Int(port)!, id: 0, regex: healthCheck)
        default:
            return nil
        }
    }
    
    func submitMonitor() async{
        print("Submitting monitor")
        let url = URL(string: "http://54.211.139.84:8080/monitors")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let monitorData = getMonitorFromUI() else {
            return
        }
        
        guard let encoded = try? JSONEncoder().encode(monitorData) else {
            print("Failed to encode monitor data")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print(String(decoding: data, as: UTF8.self))
        } catch {
            print("Checkout failed.")
        }
        
        showing = false
    }
    
    func testMonitor() async {
        print("Testing monitor")
        let url = URL(string: "http://54.211.139.84:8080/test")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let monitorData = getMonitorFromUI() else {
            return
        }
        
        guard let encoded = try? JSONEncoder().encode(monitorData) else {
            print("Failed to encode monitor data")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let monitor = try JSONDecoder().decode(Monitor.self, from: data)
            if(monitor.status) {
                tested = true
                succcess = true
            }
        } catch {
            print("Checkout failed.")
        }
    }
}
