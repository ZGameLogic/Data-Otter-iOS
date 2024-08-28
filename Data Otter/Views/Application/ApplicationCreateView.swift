//
//  ApplicationCreateView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 8/9/24.
//

import SwiftUI

struct ApplicationCreateView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
    @State var name = ""
    @State var description = ""
    @State var tags: [String: Bool] = [:]
    
    @State var newTagName = ""
    
    @Binding var isPresented: Bool
    
    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    var body: some View {
        Text("Create Application").font(.title).padding()
        Form {
            Section("Application Information"){
                TextField("Name", text: $name)
                TextField("Description", text: $description)
            }
            
            Section("Tags") {
                ForEach(Array(tags.keys), id: \.self){tag in
                    Toggle(isOn: Binding(
                        get: { tags[tag] ?? false },
                        set: { tags[tag] = $0 }
                    )) {
                        Text(tag)
                    }
                }
                TextField("New Tag Name", text: $newTagName).onSubmit {
                    tags[newTagName] = true
                    newTagName = ""
                }
            }
        }.onAppear {
            tags = viewModel.tags.reduce(into: [:]) { dict, tag in
                dict[tag.name] = false
            }
        }
    }
}

#Preview {
    Group {
        ApplicationCreateView(isPresented: .constant(true))
    }.environmentObject(DataOtterModel(
        monitorConfigurations: [],
        monitorHistoryData: [:],
        applications: [],
        tags: [
            Tag(name: "Kubernetes", description: "Anything in the cluster"),
            Tag(name: "Discord bot", description: "A discord bot")
        ]
    ))
}
