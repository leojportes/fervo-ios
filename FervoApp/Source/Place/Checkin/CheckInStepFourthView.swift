//
//  CheckInStepFourthView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 19/08/25.
//

import SwiftUI

struct CheckInStepFourthView: View {
    @EnvironmentObject var flow: CheckinViewFlow
    @Environment(\.dismiss) private var dismiss
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
        .fullScreenCover(isPresented: $flow.showSuccess) {
           CheckinResultView()
                .environmentObject(flow)
        }
        .fullScreenCover(isPresented: $flow.showError) {
           CheckinResultView()
                .environmentObject(flow)
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
                Text("Como está o movimento agora?")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.top, 35)
                    .padding(.bottom, 6)

                HStack(spacing: 4) {
                    Text("Responda e ganhe +50")
                        .font(.headline.weight(.regular))
                        .foregroundColor(.white)

                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundColor(.yellow)
                        .font(.headline)
                }
            }
            Spacer()
            CheckboxListView(selectedOption: $placeViewModel.crowdLevel)
            Spacer()

            ProgressStepsView(steps: [
                Step(title: "Ingresso", reward: 50, isCompleted: true, isCurrent: true),
                Step(title: "Música", reward: 50, isCompleted: true, isCurrent: true),
                Step(title: "Movimento", reward: 50, isCompleted: false, isCurrent: true),
                // Step(title: "Segurança", reward: 50, isCompleted: false, isCurrent: false)
            ])

            Button(action: {
                placeViewModel.makeCheckin(
                    placeID: location.fixedLocation.placeId,
                    lat: location.fixedLocation.location.lat, // TODO - Para teste, retirar e passar a localizacao do usuario.
                    lng: location.fixedLocation.location.lng
                ) { success in
                    if success {
                        flow.showSuccess = true
                    } else {
                        flow.showError = true
                    }
                }
            }) {
                Text("Finalizar check-in")
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
