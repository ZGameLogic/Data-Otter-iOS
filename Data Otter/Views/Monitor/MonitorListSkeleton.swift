//
//  MonitorListSkeleton.swift
//  Data Otter
//
//  Created by Benjamin Shabowski on 6/26/24.
//

import SwiftUI

struct MonitorListSkeleton: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("ddddddd")
            Text("fffffffffffff").font(.footnote)
            Text("asdfas").font(.footnote)
        }.redacted(reason: .placeholder).shimmering()
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [.clear, Color.white.opacity(0.4), .clear]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .rotationEffect(Angle(degrees: 30))
                    .offset(x: -UIScreen.main.bounds.width)
                    .offset(x: phase)
            )
            .mask(content)
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = UIScreen.main.bounds.width * 2
                }
            }
    }
}

extension View {
    func shimmering() -> some View {
        self.modifier(ShimmerModifier())
    }
}

#Preview {
    MonitorListSkeleton()
}
