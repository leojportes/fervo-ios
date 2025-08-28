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
    @StateObject private var viewModel: PlaceViewModel
    @State private var showTooltip = false
    @StateObject private var locationManager = LocationManager()

    init(location: LocationWithPosts, userSession: UserSession) {
        _location = State(initialValue: location)
        self.userSession = userSession
        _viewModel = StateObject(
            wrappedValue: PlaceViewModel(
                firebaseUid: userSession.currentUser?.firebaseUid ?? ""
            )
        )
    }

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

            ScrollView(showsIndicators: false) {
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
                            Label(viewModel.peoplesNowDescription, systemImage: "person.3.fill")
                                .padding(8)
                                .background(Color.fvHeaderCardbackground)
                                .cornerRadius(10)
                                .font(.caption)
                                .foregroundColor(.green)
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

                    if !viewModel.isFetchingActiveUsers {
                        if !currentUserHasCheckedIn() {
                            Button(action: {
                                guard let lat = locationManager.latitude,
                                      let lng = locationManager.longitude else { return }

                                if viewModel.isWithin10Meters(
                                    userLat: lat,
                                    userLng: lng,
                                    placeLat: location.fixedLocation.location.lat,
                                    placeLng: location.fixedLocation.location.lng
                                ) {
                                    checkinFlow.showFirst = true
                                } else {
                                    checkinFlow.showError = true
                                }


                            }) {
                                VStack {
                                    Text("Check-in")
                                        .foregroundColor(location.placeIsOpen ? .white : .gray)
                                        .font(.subheadline)

                                    HStack(spacing: 4) {
                                        Text(location.placeIsOpen ? "Ganhe 250 pontos" : location.fixedLocation.timeUntilNextOpen() ?? "")
                                            .foregroundColor(.white)
                                            .font(.caption2)
                                        if location.placeIsOpen {
                                            Image(systemName: "bitcoinsign.circle.fill")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                                .shadow(radius: 4)
                                        }
                                    }
                                }
                                .frame(maxWidth: 170)
                                .padding()
                                .background(location.placeIsOpen ? Color.blue : Color.blue.opacity(0.3))
                                .cornerRadius(15)
                            }
                            .disabled(!location.placeIsOpen)
                        } else if location.placeIsOpen && currentUserHasCheckedIn() {
                            Button(action: {
                                showTooltip = true
                            }) {
                                HStack {
                                    Text("Você está nesse local")
                                        .foregroundColor(.white)
                                        .font(.subheadline)

                                    Image(systemName: "info.circle")
                                        .foregroundColor(.black)
                                        .font(.subheadline)
                                        .shadow(radius: 4)
                                }
                                .frame(maxWidth: 190)
                                .padding()
                                .background(Color.blue.opacity(0.5))
                                .cornerRadius(15)
                            }
                        }
                    } else {
                        Spacer().frame(height: 50)
                    }


                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(location.placeIsOpen ? "Quem está no rolê agora" : "Localização")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()

                            Button {
                                viewModel.fetchActiveUsers(placeID: location.fixedLocation.placeId)
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }

                        MapContentView(
                            userSession: userSession,
                            initialCoordinate: .init(latitude: location.fixedLocation.location.lat, longitude: location.fixedLocation.location.lng),
                            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002),
                            users: location.placeIsOpen ? viewModel.activeUsers : [],
                            location: location.fixedLocation,
                            locationManager: locationManager
                        )
                        .frame(height: 200)
                        .cornerRadius(15)

                        VStack(spacing: 10) {
                            if location.placeIsOpen {
                                if viewModel.activeUsers.count > 0 {
                                    HStack(spacing: 4) {
                                        HStack(spacing: -6) {
                                            if viewModel.activeUsers.count != 0 {
                                                ForEach(viewModel.activeUsers.prefix(3), id: \.self) { user in

                                                    RemoteImage(url: URL(string: user.user.image?.photoURL ?? ""))
                                                        .frame(width: 24, height: 24)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                                }
                                            }
                                        }
                                        .padding(.leading, 6)
                                        Text(viewModel.activeUsernames)
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                        Spacer()
                                    }
                                }
                            }
                            HStack(spacing: 4) {
                                TransportDarkButton(service: .uber, destination: .coordinates(lat: location.fixedLocation.location.lat, lng: location.fixedLocation.location.lng, name: location.fixedLocation.name), style: .dark)
                                TransportDarkButton(service: .google, destination: .address(location.fixedLocation.name), style: .light)
                                Spacer()
                            }
                        }
                    }.padding(.top, 6)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Últimos posts")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if let posts = location.posts, posts.count > 0 {
                                    ForEach(posts) { post in
                                        Button(
                                            action: {
                                                self.selectedUserOfPost = post.userPost
                                            }
                                        ) {
                                            ZStack(alignment: .bottomLeading) {
                                                // Imagem principal (base)
                                                AsyncImage(url: URL(string: post.image.photoURL ?? "")) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                } placeholder: {
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .shimmering()
                                                }
                                                .frame(width: 150, height: 200)
                                                .clipped()
                                                .cornerRadius(8)

                                                // Sombra gradiente na parte inferior
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.black, Color.clear]),
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                                .frame(height: 70) // altura da sombra
                                                .cornerRadius(8, corners: [.bottomLeft, .bottomRight])

                                                HStack(alignment: .top, spacing: 5) {
                                                    AsyncImage(url: URL(string: post.userPost.image?.photoURL ?? "")) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                    } placeholder: {
                                                        Circle()
                                                            .fill(Color.gray.opacity(0.3))
                                                    }
                                                    .frame(width: 24, height: 24)
                                                    .clipShape(Circle())
                                                    .overlay(
                                                        Circle().stroke(Color.white, lineWidth: 0.5)
                                                    )


                                                    VStack(alignment: .leading) {
                                                        Text("@\(post.userPost.username)")
                                                            .font(.caption.bold())
                                                        Text("\(post.createdAt.timeAgoSinceDate)")
                                                            .font(.caption2)
                                                            .foregroundColor(.gray)
                                                    }

                                                }
                                                .padding(.leading, 6)
                                                .padding(.bottom, 6)
                                            }
                                        }

                                    }
                                } else {
                                    Text("Nenhuma postagem até agora.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                            }
                        }
                        Spacer().frame(height: 20)
                    }
                    .background(Color.FVColor.backgroundDark)
                    .padding(.top, 6)
                }
                .padding(.horizontal)
                .background(Color.FVColor.backgroundDark)
            }
            .background(Color.FVColor.backgroundDark.ignoresSafeArea())
            .blurLoading(viewModel.isFetchingActiveUsers)
        }
        .onAppear {
            if location.placeIsOpen {
                viewModel.fetchActiveUsers(placeID: location.fixedLocation.placeId)
                locationManager.requestAuthorization()
            }
        }
        .onChange(of: checkinFlow.shoudRequestActiveUsers) { oldValue, newValue in
            if newValue, location.placeIsOpen {
                viewModel.fetchActiveUsers(placeID: location.fixedLocation.placeId)
            }
        }
        .background(Color.FVColor.backgroundDark.ignoresSafeArea())
        .navigationDestination(item: $selectedUserOfPost) { userModel in
            ProfileView(userModel: userModel)
        }
        .fullScreenCover(isPresented: $checkinFlow.showFirst) {
            CheckInViewFirstStepView(placeViewModel: viewModel, location: location)
                .environmentObject(checkinFlow)
        }
        .fullScreenCover(isPresented: $checkinFlow.showError) {
            Group {
                if let lat = locationManager.latitude,
                   let lng = locationManager.longitude {
                    CheckinResultView(
                        errorMessage: "Você está longe do local. \(viewModel.formattedDistanceFrom(userLat: lat, userLng: lng, placeLat: location.fixedLocation.location.lat, placeLng: location.fixedLocation.location.lng)) de distância."
                    )
                    .environmentObject(checkinFlow)
                } else {
                    CheckinResultView(errorMessage: "")
                }
            }
        }
        .navigationBarBackButtonHidden()
        .overlay {
            if showOpeningHours {
                OpeningHoursPopup(openingHours: location.fixedLocation.weekdayText ?? [], isPresented: $showOpeningHours)
                    .zIndex(1)
            }
        }
        .overlay(
            VStack {
                if showTooltip {
                    withAnimation {
                        TooltipView(
                            text: "Ao se afastar do local, será feito o checkout.",
                            onClose: { withAnimation { showTooltip = false } }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .padding(.top, 12)
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        )
    }

    private func currentUserHasCheckedIn() -> Bool {
        viewModel.currentUserHasActiveCheckin(firebaseUid: userSession.currentUser?.firebaseUid ?? "")
    }
}
