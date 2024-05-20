//
//  AddGroupView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 5/19/24.
//

import SwiftUI

struct AddGroupView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    @Binding var isPresented: Bool
    @State var monitorToggles: [MonitorToggle] = []
    @State var groupName = ""
    @State var showAlert = false
    
    var body: some View {
        HStack {
            Button(action: {
                isPresented = false
            }, label: {
                Text("Cancel").foregroundStyle(.red)
            }).buttonStyle(.bordered).tint(.red)
            Spacer()
            Button("Submit"){ createGroup() }.buttonStyle(.bordered).tint(.green).disabled(groupName.isEmpty)
        }.padding()
        Form {
            Section("New Group Configuration") {
                TextField("Group name", text: $groupName)
            }
            Section("Monitors") {
                ForEach($monitorToggles) { $toggle in
                    Toggle(isOn: $toggle.isSelected) {
                        Text(toggle.name)
                    }
                }
            }
        }.onAppear(){
            monitorToggles = viewModel.monitorConfigurations.map({MonitorToggle(id: $0.id, name: $0.name, isSelected: false)})
        }
    }
    
    func createGroup(){
        let group = MonitorGroup(id: -1, name: groupName, monitors: monitorToggles.filter{$0.isSelected}.map{$0.id})
        viewModel.createGroup(group: group){ result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    isPresented = false
                case .failure(let error):
                    showAlert = true
                    print(error)
                }
            }
        }
    }
}
