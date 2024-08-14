//
//  ApplicationGeneralView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/9/24.
//

import SwiftUI

struct ApplicationGeneralView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
    @State var showAddApplication = false
    
    var body: some View {
        NavigationStack {
            Group {
                if(!viewModel.applicationLoading && viewModel.applications.isEmpty){ // loaded and no data
                    NoApplicationsFoundView()
                } else if(viewModel.applicationLoading) { // not loaded
                    ApplicationListSkeletonView()
                    ApplicationListSkeletonView()
                    ApplicationListSkeletonView()
                    ApplicationListSkeletonView()
                } else { // loaded and data
                    List {
                        ForEach(viewModel.applications) {
                            ApplicationListView(application: $0)
                        }
                    }
                }
            }.toolbar {
                ToolbarItem {
                    Button(action: {
                        showAddApplication = true
                    }) {
                        Label("Add Item", image: "laptopcomputer.badge.plus")
                    }
                }
            }
            .navigationTitle("Applications")
            .refreshable{ viewModel.refreshData()}
        }
    }
}

#Preview {
    ApplicationGeneralView()
}
