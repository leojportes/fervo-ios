//
//  CheckInStepFourView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 19/08/25.
//

import SwiftUI

struct CheckInStepFourView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text("Check-in")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxHeight: .infinity, alignment: .center)
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .background(Color.FVColor.backgroundDark)
                    .frame(height: 50)
                }

                HStack(alignment: .center, spacing: 20) {
                    Image("dontTellMamaLogo") // Substitua pelo nome da imagem no seu Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                        )

                    Text("Don't tell mama")
                        .font(.title2)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.leading, 20)

                VStack {
                    Text("Como está o movimento agora?")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.top, 35)
                        .padding(.bottom, 6)

                    HStack(spacing: 4) {
                        Text("Responda e ganhe +50")
                            .font(.headline)
                            .foregroundColor(.white)

                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.headline)
                    }
                }
                Spacer()
                CheckboxListView()

                Spacer()

                ProgressStepsView(steps: [
                    Step(title: "Ingresso", reward: 50, isCompleted: true, isCurrent: true),
                    Step(title: "Música", reward: 50, isCompleted: true, isCurrent: true),
                    Step(title: "Movimento", reward: 50, isCompleted: false, isCurrent: true),
                 //   Step(title: "Segurança", reward: 50, isCompleted: false, isCurrent: false)
                ])

                Button(action: {
                    print("Continuar")
                }) {
                    Text("Continuar")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: {
                    print("Continuar")
                }) {
                    Text("Pular")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .padding(.bottom)

            }
            .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
        }
        .navigationBarBackButtonHidden()
    }

}

struct CheckInStepFourView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInStepFourView()
    }
}

struct MovementOption: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
}

struct CheckboxListView: View {
    @State private var selectedOption: UUID? = nil

    let options: [MovementOption] = [
        MovementOption(title: "Pouco movimentado", emoji: "🔥"),
        MovementOption(title: "Movimentado", emoji: "🔥🔥"),
        MovementOption(title: "Muito movimentado", emoji: "🔥🔥🔥")
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options) { option in
                Button(action: {
                    selectedOption = option.id
                }) {
                    HStack {
                        Image(systemName: selectedOption == option.id ? "checkmark.square.fill" : "square")
                            .foregroundColor(selectedOption == option.id ? .fvCardBackgorund : .white)
                        Text("\(option.title) \(option.emoji)")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}
