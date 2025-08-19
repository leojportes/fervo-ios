//
//  CheckInStepTwoView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 19/08/25.
//

import SwiftUI

struct CheckInStepTwoView: View {
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
                    Text("Qual o valor do ingresso?")
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
                PriceSliderView()

                Spacer()

                ProgressStepsView(steps: [
                    Step(title: "Ingresso", reward: 50, isCompleted: false, isCurrent: true),
                    Step(title: "Música", reward: 50, isCompleted: false, isCurrent: false),
                    Step(title: "Movimento", reward: 50, isCompleted: false, isCurrent: false),
                    Step(title: "Segurança", reward: 50, isCompleted: false, isCurrent: false)
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

struct CheckInStepTwoView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInStepTwoView()
    }
}


struct PriceSliderView: View {
    @State private var price: Double = 20

    let minPrice: Double = 0
    let maxPrice: Double = 1000

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Preço")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Text("R$ \(Int(price))")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))

            }

            Slider(value: $price, in: minPrice...maxPrice, step: 5)
                .accentColor(.blue)
                .onChange(of: price) { newValue in
                    print("Novo valor: \(newValue)")
                }
        }
        .padding()
        .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
    }
}

