//
//  CheckinResultView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/08/25.
//

import SwiftUI
import Lottie

struct CheckinResultView: View {
    @EnvironmentObject var flow: CheckinViewFlow
    @Environment(\.dismiss) private var dismiss
    @State var activeButton: Bool = false
    let errorMessage: String

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                      
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
                if flow.showSuccess {
                    successContentView
                } else {
                    errorContentView
                }

            }
            .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
        }
        .navigationBarBackButtonHidden()
    }

    var successContentView: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                Text("Tudo certo!")
                    .foregroundColor(.white)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                Text("Agora é curtir seu rolê e compartilhar momentos com seus amigos.")
                    .foregroundColor(.white)
                    .font(.headline.weight(.regular))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            LottieView(animationName: "success_animation", loopMode: .playOnce)
            .frame(width: 250, height: 250)
            Spacer()

            Button(action: {
                flow.closeAll()
                flow.shoudRequestActiveUsers = true
            }) {
                Text("Ir para o local")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    var errorContentView: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                Text("Oops!")
                    .foregroundColor(.white)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text("Não foi possível realizar o checkin!")
                    .foregroundColor(.white)
                    .font(.headline.weight(.regular))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text(errorMessage)
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.regular))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            LottieView(animationName: "error_animation", loopMode: .playOnce)
                .frame(width: 250, height: 250)
            Spacer()

            Button(action: {
                dismiss()
            }) {
                Text("Tentar novamente")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

}
