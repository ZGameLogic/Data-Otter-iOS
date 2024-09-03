//
//  AddMonitorView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/14/24.
//

import SwiftUI

struct AddMonitorView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
    @State var name = ""
    @State var type = "API"
    @State var url = ""
    @State var regex = ""
    @State var applicationSelected: Application
    @State var applications: [Application]
    
    @State var confirmed = false
    @State var showAlert = false
    
    var preSelected: Bool = false
    
    @Binding var isPresented: Bool
    
    init(applicationSelected: Application? = nil, applications: [Application], preSelected: Bool? = nil, isPresented: Binding<Bool>) {
        if let applicationSelected = applicationSelected {
            self.applicationSelected = applicationSelected
        } else {
            self.applicationSelected = applications[0]
        }
        self.applications = applications
        if let preSelected = preSelected {
            self.preSelected = preSelected
        }
        self._isPresented = isPresented
    }
    
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
                    viewModel.createMonitor(monitorData: MonitorData(name: name, type: type, url: url, regex: regex), applicationId: applicationSelected.id) { result in
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
                Picker("Application", selection: $applicationSelected) {
                    ForEach(applications, id: \.self){
                        Text($0.name).tag($0.id)
                    }
                }.pickerStyle(MenuPickerStyle())
                    .disabled(preSelected)
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
                title: Text("Unable to create monitor"),
                message: Text("Verify the information in this form and try again."),
                dismissButton: .default(Text("Close"))
            )
        }
    }
}
