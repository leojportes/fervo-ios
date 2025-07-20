//
//  PlaceView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/07/25.
//

import SwiftUI
import MapKit

struct PlaceView: View {
    @State var location: LocationWithPosts
    let userSession: UserSession
    @Environment(\.dismiss) private var dismiss

    @State private var selectedUserOfPost: UserModel?

    var body: some View {
        NavigationStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding([.horizontal, .top], 10)
                }
                Text(location.fixedLocation.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                }
                .foregroundColor(.white)
            }
            .padding(.horizontal)
            .background(Color.FVColor.backgroundDark)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
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

                        VStack(alignment: .leading, spacing: 4) {

                            Text(location.placeIsOpen ? "Aberto" : "Fechado")
                                .font(.caption)
                                .foregroundColor(location.placeIsOpen ? .green : .red)

                            Text(location.todayOpeningHours)
                                .foregroundColor(.gray)
                                .font(.caption)
                        }

                        Spacer()
                    }

                    // Prices and Details
                    HStack(spacing: 8) {
                        Text(location.fixedLocation.mapPriceLevelToString)
                            .padding(8)
                            .background(Color.fvHeaderCardbackground)
                            .cornerRadius(10)
                            .font(.caption)
                            .foregroundColor(.white)

                        if let rating = location.fixedLocation.rating?.description {
                            Label("\(rating)", systemImage: "star.fill")
                                .padding(8)
                                .background(Color.fvHeaderCardbackground)
                                .cornerRadius(10)
                                .font(.caption)
                                .foregroundColor(.white)
                        }

                        Label("236 pessoas agora", systemImage: "person.2.fill")
                            .padding(8)
                            .background(Color.fvHeaderCardbackground)
                            .cornerRadius(10)
                            .font(.caption)
                            .foregroundColor(.white)

                        if let website = location.fixedLocation.website,
                           let url = URL(string: website) {
                            Button(action: {
                                UIApplication.shared.open(url)
                            }) {
                                Image(systemName: "link")
                                    .padding(8)
                                    .background(Color.blue.opacity(0.7))
                                    .cornerRadius(10)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    // Confirm Button
                    Button(action: {}) {
                        Text("Confirmar Presença")
                            .frame(maxWidth: 160)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [
                                            Color.fvHeaderCardbackground,
                                            Color.blue
                                        ]
                                    ),
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }

    //                // Participants
    //                HStack(spacing: -15) {
    //                    ForEach(0..<3) { _ in
    //                        Image("profile") // Substitua para imagens diferentes se quiser
    //                            .resizable()
    //                            .scaledToFill()
    //                            .frame(width: 40, height: 40)
    //                            .clipShape(Circle())
    //                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
    //                    }
    //
    //                    Text("+25")
    //                        .foregroundColor(.gray)
    //                        .font(.subheadline)
    //                        .padding(.leading, 8)
    //                }
    //                .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Localização")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)

                        MapView(
                            coordinate: .init(latitude: location.fixedLocation.location.lat, longitude: location.fixedLocation.location.lng),
                            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                        )
                        .frame(height: 200)
                        .cornerRadius(15)

                        HStack {
                            Spacer()
                            Label("236 no rolê", systemImage: "person.3.fill")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Últimos posts")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(location.posts) { post in
                                    Button(
                                        action: {
                                            self.selectedUserOfPost = post.userPost
                                        }
                                    ) {
                                        AsyncImage(url: URL(string: post.image.photoURL ?? "")) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .shimmering()
                                        }
                                        .frame(width: 120, height: 160)
                                        .clipped()
                                        .cornerRadius(8)
                                    }

                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.FVColor.backgroundDark)
        .onAppear() {
            customizeNavigationBar()
        }
        .navigationDestination(item: $selectedUserOfPost) { userModel in
            ProfileView(userModel: userModel)
        }
        .navigationBarBackButtonHidden()
    }

    private func customizeNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.gray
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
