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
    var showProgressView: Bool = true
    @State private var internalActive: Bool = false

    func body(content: Content) -> some View {
        Group {
            if internalActive {
                if showProgressView {
                    content
                        .blur(radius: 4)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                                .font(.caption)
                        )
                        .allowsHitTesting(false)
                } else {
                    content
                        .blur(radius: 8)
                        .allowsHitTesting(false)
                }
            } else {
                content
            }
        }
        .onChange(of: isActive) { newValue in
            if newValue {
                // ativa imediatamente
                internalActive = true
            } else {
                // mantém pelo menos 2 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    internalActive = false
                }
            }
        }
        .onAppear {
            if isActive { internalActive = true }
        }
    }
}

extension View {
    func blurLoading(_ isActive: Bool = true, _ isShowingProgressView: Bool = true) -> some View {
        self.modifier(BlurLoading(isActive: isActive, showProgressView: isShowingProgressView))
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
