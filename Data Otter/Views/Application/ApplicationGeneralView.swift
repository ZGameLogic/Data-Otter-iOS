//
//  ApplicationGeneralView.swift
//  Monitors
//
//  Created by Benjamin Shabowski on 8/9/24.
//

import SwiftUI

struct ApplicationGeneralView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    
    var body: some View {
        NavigationStack {
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
                .navigationTitle("Applications")
                .refreshable{ viewModel.refreshData()}
            }
        }
    }
}

#Preview {
    ApplicationGeneralView()
}
