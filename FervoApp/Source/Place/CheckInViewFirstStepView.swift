//
//  CheckInViewFirstStepView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 18/08/25.
//

import SwiftUI

struct CheckInViewFirstStepView: View {
    @EnvironmentObject var flow: CheckinViewFlow
    @Environment(\.dismiss) private var dismiss
    @State var nextStep: Bool = false
    @StateObject private var placeViewModel = PlaceViewModel()
    @State var location: LocationWithPosts

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
                    Text("Como está o \(location.fixedLocation.name)?")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.top, 35)
                        .padding(.bottom, 6)

                    HStack(spacing: 4) {
                        Text("Responda e ganhe até 250")
                            .font(.headline.weight(.regular))
                            .foregroundColor(.white)

                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.headline)
                    }
                }

                AsyncImage(url: URL(string: location.fixedLocation.photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .shimmering()
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .padding(.top)

                Text("Se você não está no \(location.fixedLocation.name), aproxime-se do local correto e realize o check-in novamente.")
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
                    flow.showSecond = true
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
        .fullScreenCover(isPresented: $flow.showSecond) {
            CheckInStepTwoView(placeViewModel: placeViewModel, location: location)
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



//
//struct CheckInViewStepOneView_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckInViewStepOneView()
//    }
//}
//

