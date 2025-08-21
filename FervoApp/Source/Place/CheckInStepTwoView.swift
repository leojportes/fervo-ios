//
//  CheckInStepTwoView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 19/08/25.
//

import SwiftUI

struct CheckInStepTwoView: View {
    @EnvironmentObject var flow: CheckinViewFlow
    @Environment(\.dismiss) private var dismiss
    @State var nextStep: Bool = false
    @StateObject var placeViewModel: PlaceViewModel
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
                contentView
            }
            .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $flow.showThird) {
            CheckInStepThreeView(placeViewModel: placeViewModel, location: location)
        }
    }

    var contentView: some View {
        VStack {
            HStack(alignment: .center, spacing: 20) {
                AsyncImage(url: URL(string: location.fixedLocation.photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .shimmering()
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .padding(.top)

                Text(location.fixedLocation.name)
                    .font(.title2)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.leading, 20)

            VStack {
                Text("Qual o preço do ingresso?")
                    .font(.headline.weight(.regular))
                    .foregroundColor(.white)
                    .padding(.top, 35)
                    .padding(.bottom, 6)

                HStack(spacing: 4) {
                    Text("Responda e ganhe +50")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.headline)
                }
            }
            Spacer()
            PriceSliderView(price: $placeViewModel.price)

            Spacer()

            ProgressStepsView(steps: [
                Step(title: "Ingresso", reward: 50, isCompleted: false, isCurrent: true),
                Step(title: "Música", reward: 50, isCompleted: false, isCurrent: false),
                Step(title: "Movimento", reward: 50, isCompleted: false, isCurrent: false),
              //  Step(title: "Segurança", reward: 50, isCompleted: false, isCurrent: false)
            ])

            Button(action: {
                flow.showThird = true
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
                print("pular")
            }) {
                Text("Pular")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

}

struct PriceSliderView: View {
    @Binding var price: Double

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
        }
        .padding()
        .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
    }
}

