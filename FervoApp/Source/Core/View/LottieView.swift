//
//  LottieView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 24/08/25.
//

import Lottie
import SwiftUI
import UIKit

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)

        // Cria a animação
        let animation = LottieAnimation.named(animationName)
        let animationView = LottieAnimationView(animation: animation)

        animationView.mainThreadRenderingEngineShouldForceDisplayUpdateOnEachFrame = true
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        // Adiciona a animação à view
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
