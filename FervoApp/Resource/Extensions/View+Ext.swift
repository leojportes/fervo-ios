//
//  View+Ext.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/07/25.
//
import SwiftUI

struct Shimmer: ViewModifier {
    var isActive: Bool
    @State private var phase: CGFloat = -100

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, Color.white.opacity(0.4), .clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: phase)
                        .blendMode(.plusLighter)
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: 1.5).repeatForever(autoreverses: false)
                            ) {
                                phase = geometry.size.width + 200
                            }
                        }
                    }
                )
                .mask(content)
        } else {
            content
        }
    }
}

extension View {
    func shimmering(_ isActive: Bool = true) -> some View {
        self.modifier(Shimmer(isActive: isActive))
    }
}

struct BlurLoading: ViewModifier {
    var isActive: Bool

    func body(content: Content) -> some View {
        if isActive {
            content
                .blur(radius: 4) // 👈 Aplica o blur
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .font(.caption)
                )
                .allowsHitTesting(false) // 👈 Bloqueia toques enquanto está no loading
        } else {
            content
        }
    }
}

extension View {
    func blurLoading(_ isActive: Bool = true) -> some View {
        self.modifier(BlurLoading(isActive: isActive))
    }
}
