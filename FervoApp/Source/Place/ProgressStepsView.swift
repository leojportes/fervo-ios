//
//  ProgressStepsView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 19/08/25.
//

import SwiftUI

struct Step: Identifiable {
    let id = UUID()
    let title: String
    let reward: Int
    let isCompleted: Bool
    let isCurrent: Bool
}

struct ProgressStepsView: View {
    let steps: [Step]

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    VStack(spacing: 8) {
                        HStack(spacing: 2) {
                            Text("+\(step.reward)")
                                .foregroundColor(step.isCurrent ? .yellow : .gray)
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundColor(step.isCurrent ? .yellow : .gray.opacity(0.6))
                        }

                        ZStack {
                            Circle()
                                .fill(step.isCompleted || step.isCurrent ? Color.green : Color.black)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(step.isCompleted ? Color.green : Color.white, lineWidth: 1)
                                )

                            Image(systemName: "checkmark")
                                .foregroundColor(step.isCompleted || step.isCurrent ? .white : .gray)
                                .font(.system(size: 10, weight: .bold))
                        }

                        // Título
                        Text(step.title)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }

                    // Linha entre steps
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(height: 2)
                            .padding(.horizontal, -10)
                    }
                }
            }
        }
        .padding()
        .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
    }
}
