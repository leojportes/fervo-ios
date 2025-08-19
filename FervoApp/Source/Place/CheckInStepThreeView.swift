//
//  CheckInStepThreeView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 19/08/25.
//


import SwiftUI

struct CheckInStepThreeView: View {
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
                    Text("Qual gênero musical está tocando?")
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
                MusicStyleSelectorView()

                Spacer()

                ProgressStepsView(steps: [
                    Step(title: "Ingresso", reward: 50, isCompleted: true, isCurrent: true),
                    Step(title: "Música", reward: 50, isCompleted: false, isCurrent: true),
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

                Button(action: {
                    print("Pular")
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
        .fullScreenCover(isPresented: $nextStep) {
            CheckInStepFourView()
        }
    }

}

struct CheckInStepThreeView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInStepThreeView()
    }
}

struct MusicStyle: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let image: String
}

struct MusicStyleSelectorView: View {
    let styles: [MusicStyle] = [
        MusicStyle(name: "Eletrônico", image: "music.note"),
        MusicStyle(name: "Hip Hop", image: "music.note"),
        MusicStyle(name: "Funk", image: "music.note"),
        MusicStyle(name: "Rap", image: "music.note"),
        MusicStyle(name: "MPB", image: "music.note"),
        MusicStyle(name: "Trap", image: "music.note"),
        MusicStyle(name: "Pagode", image: "music.note"),
        MusicStyle(name: "Pop", image: "music.note")
    ]

    @State private var selectedStyles: Set<MusicStyle> = []

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(styles) { style in
                VStack {
                    Text(style.name)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))

                    Image(systemName: style.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedStyles.contains(style) ? Color.blue : Color.clear, lineWidth: 3)
                        )
                }
                .onTapGesture {
                    if selectedStyles.contains(style) {
                        selectedStyles.remove(style)
                    } else {
                        selectedStyles.insert(style)
                    }
                }
            }
        }
        .padding()
        .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
    }
}
