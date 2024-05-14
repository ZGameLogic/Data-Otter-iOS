//
//  MonitorDetailView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/13/24.
//

import SwiftUI

struct MonitorDetailView: View {
    @Binding var monitor: MonitorStatus
    var history: [Status]
    @State var showEditMonitor = false
    
    var body: some View {
        VStack {
            Text(monitor.name).font(.title)
            if let status = monitor.status {
                Text(status.status ? "Online" : "Offline").foregroundStyle(monitor.getStatusColor())
            }
            Form {
                Section("General Information") {
                    Text("URL: \(monitor.url)")
                    Text("Type: \(monitor.type)")
                    Text("Regex: \(monitor.regex)")
                }
            }
            Spacer()
        }.toolbar {
            ToolbarItem {
                Button(action: {
                    showEditMonitor = true
                }) {
                    Label("Edit Item", systemImage: "square.and.pencil")
                }
            }
        }.sheet(isPresented: $showEditMonitor, content: {
            EditMonitorView(monitor: $monitor, showing: $showEditMonitor)
        }).onAppear{
            print(history.count)
        }
    }
}

struct EditMonitorView: View {
    @Binding var monitor: MonitorStatus
    @Binding var showing: Bool
    
    @State var confirmed = false
    @State var showAlert = false
    @State var name = ""
    @State var url = ""
    @State var type = ""
    @State var regex = ""

    var body: some View {
        HStack {
            Button(action: {
                showing = false
            }, label: {
                Text("Cancel").foregroundStyle(.red)
            })
            Spacer()
            if(!confirmed){
                Button("Verify"){
                    MonitorsService.testMonitor(monitorData: MonitorData(name: name, type: type, url: url, regex: regex)) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let data):
                                if(data.status){
                                    confirmed = true
                                } else {
                                    showAlert = true
                                }
                            case .failure(let error):
                                showAlert = true
                                print(error)
                            }
                        }
                    }
                }
            } else {
                Button("Submit"){
                    monitor.update(data: MonitorData(name: name, type: type, url: url, regex: regex))
                    MonitorsService.updateMonitor(monitorData: monitor) { _ in
                        showing = false
                    }
                }
            }
        }.padding()
        Form {
            Section("Edit Monitor Information") {
                TextField("Name", text: $name).disabled(confirmed)
                TextField("URL", text: $url).disabled(confirmed)
                Picker("Type", selection: $type) {
                    Text("API").tag("API")
                    Text("Web").tag("WEB")
                }.pickerStyle(.segmented).disabled(confirmed)
                TextField("Regex", text: $regex).disabled(confirmed)
            }
        }
        .navigationTitle("Edit Monitor")
        .onAppear {
            name = monitor.name
            url = monitor.url
            type = monitor.type
            regex = monitor.regex
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Unable to edit monitor"),
                message: Text("Verify the information in this form and try again."),
                dismissButton: .default(Text("Close"))
            )
        }
    }
}

#Preview {
    MonitorDetailView(monitor: Binding.constant(MonitorStatus(id: 1, name: "Test Monitor", type: "API", url: "https://zgamelogic.com", regex: "Healthy", status: Status(dateRecorded: Date(), milliseconds: 3, status: true, attempts: 1, statusCode: 200))), history: [])
}
