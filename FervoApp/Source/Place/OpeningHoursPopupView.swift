//
//  OpeningHoursPopupView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 17/08/25.
//


import SwiftUI

struct OpeningHoursPopup: View {
    let openingHours: [String]

    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 0) {
                HStack {
                    Text("Horários de funcionamento")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()

                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(openingHours, id: \.self) { day in
                            Text(day)
                                .font(.subheadline)
                                .foregroundColor(day.contains("Fechado") ? .red : .white)
                        }
                    }
                    .padding()
                    Spacer()
                }
            }
            .frame(maxWidth: 340)
            .background(Color.black.opacity(0.4))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

