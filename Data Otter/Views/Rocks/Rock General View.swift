//
//  Rock General View.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 1/27/25.
//

import SwiftUI

struct RockGeneralView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
    let appId: Int64
    
    @State var availableFields: [String: Bool] = [:]
    @State var showFields = true
    
    var body: some View {
        List {
            if showFields {
                Section("Fields") {
                    ForEach(availableFields.keys.sorted(), id: \.self) { key in
                        Toggle(key, isOn: Binding(
                            get: { availableFields[key] ?? false },
                            set: { availableFields[key] = $0 }
                        ))
                    }
                }
            }
            ForEach(viewModel.rocks[appId] ?? []) { rock in
                switch(rock.pebble) {
                case .dictionary(let dict):
                    VStack(alignment: .leading) {
                        ForEach(availableFields.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            if value {
                                if let f = dict[key] as? String {
                                    Text("\(key): \(f)")
                                }
                            }
                        }
                    }
                case .string(let string):
                    Text(string)
                }
            }
            Button("Load more", action: fetch)
                .disabled(viewModel.rockPages[appId]?.last ?? false)
        }.onAppear(perform: fetch)
            .onChange(of: viewModel.rocks[appId]) {
                getAvailableFields()
            }
    }
    
    func fetch(){
        viewModel.fetchMoreApplicationRocks(applicationId: appId)
    }
    
    func getAvailableFields() {
        if let rocks = viewModel.rocks[appId] {
            let fields = Set(rocks.flatMap { rock in
                switch rock.pebble {
                case .string:
                    return [] as [String]
                case .dictionary(let data):
                    return Array(data.keys)
                }
            })
            
            for f in fields {
                if !availableFields.keys.contains(f) {
                    availableFields[f] = false
                }
            }
        }
    }
}

#Preview {
    RockGeneralView(appId: 2)
}
