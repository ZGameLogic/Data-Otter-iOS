//
//  ApplicationListSkeletonView.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 8/9/24.
//

import SwiftUI

struct ApplicationListSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("ddddddd").font(.title)
            Text("fffffffffffff")
            Text("asdfas")
        }.redacted(reason: .placeholder).shimmering()
    }
}

#Preview {
    ApplicationListSkeletonView()
}
