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
    @State private var showOpeningHours = false
    @StateObject var checkinFlow = CheckinViewFlow()

    @State private var selectedUserOfPost: UserModel?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding([.horizontal], 10)
                    }
                    Text(location.fixedLocation.name)
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

                            if location.fixedLocation.weekdayText != nil {
                                Button {
                                    withAnimation { showOpeningHours = true }
                                } label: {
                                    HStack {
                                        Text(location.todayOpeningHours)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                            .frame(width: 4, height: 4)
                                    }
                                }
                            }
                        }

                        Spacer()
                    }
                    .background(Color.FVColor.backgroundDark)

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

                        if location.placeIsOpen {
                            Label("236 pessoas agora", systemImage: "person.2.fill")
                                .padding(8)
                                .background(Color.fvHeaderCardbackground)
                                .cornerRadius(10)
                                .font(.caption)
                                .foregroundColor(.white)
                        }

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

                  //  if location.placeIsOpen {
                        Button(action: {
                            checkinFlow.showFirst = true
                        }) {
                            Text("Check-in")
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

                        if location.placeIsOpen {
                            HStack {
                                Spacer()
                                Label("236 no rolê", systemImage: "person.3.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Últimos posts")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if let posts = location.posts {
                                    ForEach(posts) { post in
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
                    .background(Color.FVColor.backgroundDark)
                }
                .padding(.horizontal)
                .background(Color.FVColor.backgroundDark)
            }
            .background(Color.FVColor.backgroundDark.ignoresSafeArea())
        }
        .background(Color.FVColor.backgroundDark.ignoresSafeArea())
        .navigationDestination(item: $selectedUserOfPost) { userModel in
            ProfileView(userModel: userModel)
        }
        .fullScreenCover(isPresented: $checkinFlow.showFirst) {
            CheckInViewFirstStepView(location: location)
                .environmentObject(checkinFlow)
        }
        .navigationBarBackButtonHidden()
        .overlay {
            if showOpeningHours {
                OpeningHoursPopup(openingHours: location.fixedLocation.weekdayText ?? [], isPresented: $showOpeningHours)
                    .zIndex(1)
            }
        }
    }
}

class CheckinViewFlow: ObservableObject {
    @Published var showFirst = false
    @Published var showSecond = false
    @Published var showThird = false
    @Published var showFourth = false
    @Published var showSuccess = false

    func closeAll() {
        showFourth = false
        showSuccess = false
        showThird = false
        showSecond = false
        showFirst = false
    }
}
