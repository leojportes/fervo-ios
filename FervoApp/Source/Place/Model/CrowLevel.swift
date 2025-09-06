//
//  CrowLevel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 28/08/25.
//

import SwiftUI

enum CrowdLevel: String, CaseIterable, Identifiable {
    case low, medium, hard
    var id: String { rawValue }

    var title: String {
        switch self {
        case .low: return "Pouco movimentado"
        case .medium: return "Movimentado"
        case .hard: return "Muito movimentado"
        }
    }

    private var lottieFilename: String {
        switch self {
        case .low: return "fire_icon"
        case .medium: return "fire_icon"
        case .hard: return "fire_icon"
        }
    }

    @ViewBuilder
    var emojiView: some View {
        VStack {
            switch self {
            case .low:
                HStack(spacing: 0) {
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                }
            case .medium:
                HStack(spacing: 0) {
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                }
            case .hard:
                HStack(spacing: 0) {
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                }
            }
        }.padding(.bottom, 10)
    }

    private var frameSize: CGFloat {
        switch self {
        case .low: return 26
        case .medium: return 26
        case .hard: return 26
        }
    }
}
