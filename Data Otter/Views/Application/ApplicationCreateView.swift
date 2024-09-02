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
    @State var submitting = false
    
    @Binding var isPresented: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                isPresented = false
            }, label: {
                Text("Cancel").foregroundStyle(.red)
            }).buttonStyle(.bordered).tint(.red)
                .padding()
            Spacer()
            Button(action: {
                submitting = true
                let app = ApplicationCreateData(
                    name: name,
                    description: description.isEmpty ? nil : description,
                    tags: tags.filter{$0.value}.map{Tag(name: $0.key, description: nil)}
                )
                viewModel.createApplication(applicationData: app){ result in
                    DispatchQueue.main.async {
                        switch(result){
                        case .success(let data):
                            viewModel.applications.append(data)
                            isPresented = false
                        case .failure(let error):
                            // TODO do an error
                            print(error)
                        }
                    }
                }
            }, label: {
                if(submitting){
                    ProgressView().progressViewStyle(.circular)
                } else {
                    Text("Submit")
                }
            }).buttonStyle(.bordered).tint(.green).disabled(submitting)
                .padding()
        }
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
        }.onAppear{
            self.tags = viewModel.tags.reduce(into: [:]) { dict, tag in
                dict[tag.name] = false
            }
        }
    }
}
