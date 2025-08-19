//
//  CheckInViewStepOneView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 18/08/25.
//

import SwiftUI

struct CheckInViewStepOneView: View {
    @Environment(\.dismiss) private var dismiss
    @State var nextStep: Bool = false

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

                VStack {
                    Text("Como está o Don't Tell Mama agora?")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.top, 35)
                        .padding(.bottom, 6)

                    HStack(spacing: 4) {
                        Text("Responda e ganhe até 250")
                            .font(.headline)
                            .foregroundColor(.white)

                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.headline)
                    }
                }

                Image("dontTellMamaLogo") // Substitua pelo nome da imagem no seu Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 3)
                    )
                    .padding(.top)

                Text("Se você não está no Don't Tell Mama, aproxime-se do local correto e realize o check-in novamente.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                ProgressStepsView(steps: [
                    Step(title: "Ingresso", reward: 50, isCompleted: false, isCurrent: false),
                    Step(title: "Música", reward: 50, isCompleted: false, isCurrent: false),
                    Step(title: "Movimento", reward: 50, isCompleted: false, isCurrent: false),
                  //  Step(title: "Segurança", reward: 50, isCompleted: false, isCurrent: false)
                ])

                Button(action: {
                    nextStep = true
                }) {
                    Text("Continuar")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Text("Ao clicar em continuar, você concorda com os nossos Termos de Serviço e com a Política de Privacidade")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

            }
            .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $nextStep) {
            CheckInStepTwoView()
        }
    }

}

struct CheckItem: View {
    var title: String

    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.blue)
                .font(.title2)
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

struct CheckInViewStepOneView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInViewStepOneView()
    }
}


