//
//  AddMonitorView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/14/24.
//

import SwiftUI

struct AddMonitorView: View {
    @State var name = ""
    @State var type = "API"
    @State var url = ""
    @State var regex = ""
    
    @State var confirmed = false
    @State var showAlert = false
    
    @Binding var isPresented: Bool
    
    
    var body: some View {
        HStack {
            Button(action: {
                isPresented = false
            }, label: {
                Text("Cancel").foregroundStyle(.red)
            }).buttonStyle(.bordered).tint(.red)
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
                }.buttonStyle(.bordered).tint(.blue)
            } else {
                Button("Submit"){
                    MonitorsService.createMonitor(monitorData: MonitorData(name: name, type: type, url: url, regex: regex)) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success( _):
                                isPresented = false
                            case .failure(let error):
                                confirmed = false
                                showAlert = true
                                print(error)
                            }
                        }
                    }
                }.buttonStyle(.bordered).tint(.green)
            }
        }.padding()
        Text("Create Monitor").font(.title).padding()
        Form {
            Section("Monitor Information"){
                TextField("Name", text: $name)
                Picker("Type", selection: $type) {
                    Text("API").tag("API")
                    Text("Web").tag("WEB")
                }.pickerStyle(.segmented)
                TextField("URL", text: $url).keyboardType(.URL)
                TextField("Regex", text: $regex)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Unable to edit monitor"),
                message: Text("Verify the information in this form and try again."),
                dismissButton: .default(Text("Close"))
            )
        }
    }
}

#Preview {
    AddMonitorView(isPresented: Binding.constant(true))
}
