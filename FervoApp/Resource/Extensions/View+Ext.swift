//
//  View+Ext.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/07/25.
//

import SwiftUI

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -100

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(gradient: Gradient(colors: [.clear, Color.white.opacity(0.4), .clear]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: phase)
                        .blendMode(.plusLighter)
                        .onAppear {
                            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                phase = geometry.size.width + 200
                            }
                        }
                }
            )
            .mask(content)
    }
}

extension View {
    func shimmering() -> some View {
        self.modifier(Shimmer())
    }
}
