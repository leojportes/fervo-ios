//
//  MapContentView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 28/08/25.
//

import SwiftUI
import MapKit
import Combine
import CoreLocation

// MARK: - MapContentView
struct MapContentView: View {
    @State private var selectedUser: UserModel?
    @State private var resetTrigger = false
    let userSession: UserSession

    let initialCoordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    let users: [CheckinActiveUserResponse]?
    let location: FixedLocation
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                MapView(
                    coordinate: initialCoordinate,
                    span: span,
                    resetTrigger: $resetTrigger,
                    users: users,
                    location: location,
                    locationManager: locationManager,
                    userSession: userSession
                )
                .edgesIgnoringSafeArea(.all)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserAnnotationTapped"))) { notif in
                    if let user = notif.userInfo?["userModel"] as? UserModel {
                        selectedUser = user
                    }
                }

                Button(action: { resetTrigger = true }) {
                    Image(systemName: "scope")
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
            .sheet(isPresented: Binding(
                get: { selectedUser != nil },
                set: { if !$0 { selectedUser = nil } }
            )) {
                if let user = selectedUser {
                    ProfileView(userModel: user)
                }
            }
        }
    }
}
