//
//  CheckInStepThreeView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 19/08/25.
//


import SwiftUI

struct CheckInStepThreeView: View {
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
        .fullScreenCover(isPresented: $flow.showFourth) {
            CheckInStepFourthView(placeViewModel: placeViewModel, location: location)
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
                Text("Qual gênero musical está tocando?")
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
            MusicStyleSelectorView(selectedStyles: $placeViewModel.musicalTaste)

            Spacer()

            ProgressStepsView(steps: [
                Step(title: "Ingresso", reward: 50, isCompleted: true, isCurrent: true),
                Step(title: "Música", reward: 50, isCompleted: false, isCurrent: true),
                Step(title: "Movimento", reward: 50, isCompleted: false, isCurrent: false),
              //  Step(title: "Segurança", reward: 50, isCompleted: false, isCurrent: false)
            ])

            Button(action: {
                flow.showFourth = true
            }) {
                Text("Continuar")
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

struct MusicStyle: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let image: String
}

struct MusicStyleSelectorView: View {
    let styles: [MusicStyle] = [
        MusicStyle(name: "Eletro", image: ""),
        MusicStyle(name: "Hip Hop", image: ""),
        MusicStyle(name: "Funk", image: ""),
        MusicStyle(name: "Rap", image: ""),
        MusicStyle(name: "MPB", image: ""),
        MusicStyle(name: "Trap", image: ""),
        MusicStyle(name: "Pagode", image: ""),
        MusicStyle(name: "Pop", image: "")
    ]

    @Binding var selectedStyles: [String]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(styles) { style in
                VStack {
                    ZStack {
                        // Fundo escuro
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.black)
                            .frame(width: 75, height: 75)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(selectedStyles.contains(style.name) ? Color.blue : Color.clear, lineWidth: 3)
                            )

                        Text(style.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                    }
                }
                .onTapGesture {
                    if selectedStyles.contains(style.name) {
                        selectedStyles.removeAll(where: { $0 == style.name })
                    } else {
                        selectedStyles.append(style.name)
                    }
                }
            }
        }
        .padding()
        .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
    }
}
