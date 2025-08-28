//
//  MapView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/07/25.
//

import SwiftUI
import MapKit
import Combine
import CoreLocation

// MARK: - MapView
struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    @Binding var resetTrigger: Bool
    let users: [CheckinActiveUserResponse]?
    let location: FixedLocation
    @ObservedObject var locationManager: LocationManager
    let userSession: UserSession

    func makeCoordinator() -> MapCoordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.pointOfInterestFilter = .excludingAll
        mapView.overrideUserInterfaceStyle = .dark
        mapView.delegate = context.coordinator

        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)

        if let userCoord = locationManager.currentLocation {
            let distance = formattedDistanceFrom(
                userLat: userCoord.latitude,
                userLng: userCoord.longitude,
                placeLat: location.location.lat,
                placeLng: location.location.lng
            )

            let annotation = PlaceAnnotation(
                coordinate: coordinate,
                location: location,
                distance: distance
            )
            mapView.addAnnotation(annotation)
        }

        // Usuários ativos
        addUserAnnotations(to: mapView)

        // Pin do usuário
        addUserPin(to: mapView)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if resetTrigger {
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: true)
            DispatchQueue.main.async { resetTrigger = false }
        }

        // Atualiza pins dos usuários
        updateUserAnnotations(on: uiView)

        // Atualiza pin do usuário
        updateUserPin(on: uiView)

        if let userCoord = locationManager.currentLocation {
            for annotation in uiView.annotations {
                if let placeAnnotation = annotation as? PlaceAnnotation {
                    placeAnnotation.distance = formattedDistanceFrom(
                        userLat: userCoord.latitude,
                        userLng: userCoord.longitude,
                        placeLat: placeAnnotation.coordinate.latitude,
                        placeLng: placeAnnotation.coordinate.longitude
                    )
                    if let view = uiView.view(for: placeAnnotation) as? PlaceAnnotationView {
                        view.updateDistanceLabel(with: placeAnnotation.distance)
                    }
                }
            }
        }
    }

    private func updateUserAnnotations(on mapView: MKMapView) {
        guard let users = self.users else { return }
        let existingAnnotations = mapView.annotations.compactMap { $0 as? UserAnnotation }

        // Remove apenas anotações de usuários que não existem mais
        let existingUserIds = existingAnnotations.map { $0.userModel.id }
        let newUserIds = users.map { $0.user.id }
        let toRemove = existingAnnotations.filter { !newUserIds.contains($0.userModel.id) }
        mapView.removeAnnotations(toRemove)

        // Adiciona apenas novos usuários
        for user in users {
            if !existingUserIds.contains(user.user.id) {
                let baseCoord = coordinate
                let baseRadius: Double = 5
                let zoomFactor = max(span.latitudeDelta, span.longitudeDelta)
                let radius: Double = baseRadius + (zoomFactor * 500)
                let index = users.firstIndex(where: { $0.user.id == user.user.id })!
                let angle = (2 * Double.pi / Double(users.count)) * Double(index)
                let dx = radius * cos(angle)
                let dy = radius * sin(angle)
                let coord = baseCoord.offsetBy(latMeters: dy, lonMeters: dx)
                let annotation = UserAnnotation(coordinate: coord,
                                                imageURL: URL(string: user.user.image?.photoURL ?? ""),
                                                userModel: user.user)
                mapView.addAnnotation(annotation)
            }
        }
    }

    private func updateUserPin(on mapView: MKMapView) {
        if doesNotContainUserInPlace {
            if let existingUserPin = mapView.annotations.first(where: { $0.title == "Você" }) as? MKPointAnnotation {
                // Atualiza coordenada
                if let userCoord = locationManager.currentLocation {
                    existingUserPin.coordinate = userCoord
                }
            } else if let userCoord = locationManager.currentLocation {
                // Adiciona se não existir
                let userAnnotation = MKPointAnnotation()
                userAnnotation.coordinate = userCoord
                userAnnotation.title = "Você"
                mapView.addAnnotation(userAnnotation)
            }
        }
    }

    private func addUserAnnotations(to mapView: MKMapView) {
        guard let users = self.users else { return }
        let baseCoord = coordinate
        let baseRadius: Double = 5
        let zoomFactor = max(span.latitudeDelta, span.longitudeDelta)
        let radius: Double = baseRadius + (zoomFactor * 500)
        let count = users.count

        for (index, user) in users.enumerated() {
            let angle = (2 * Double.pi / Double(count)) * Double(index)
            let dx = radius * cos(angle)
            let dy = radius * sin(angle)
            let coord = baseCoord.offsetBy(latMeters: dy, lonMeters: dx)

            let annotation = UserAnnotation(
                coordinate: coord,
                imageURL: URL(string: user.user.image?.photoURL ?? ""),
                userModel: user.user
            )
            mapView.addAnnotation(annotation)
        }
    }

    var doesNotContainUserInPlace: Bool {
        if let currentUserId = userSession.currentUser?.firebaseUid, let users = users, users.filter({ $0.user.firebaseUid == currentUserId }).isEmpty {
            return true
        }
        return false
    }

    private func addUserPin(to mapView: MKMapView) {
        if doesNotContainUserInPlace {
            mapView.removeAnnotations(mapView.annotations.filter { $0.title == "Você" })
            if let userCoord = locationManager.currentLocation {
                let userAnnotation = MKPointAnnotation()
                userAnnotation.coordinate = userCoord
                userAnnotation.title = "Você"
                mapView.addAnnotation(userAnnotation)
            }
        }
    }

    func formattedDistanceFrom(userLat: Double, userLng: Double, placeLat: Double, placeLng: Double) -> String {
        let userLocation = CLLocation(latitude: userLat, longitude: userLng)
        let placeLocation = CLLocation(latitude: placeLat, longitude: placeLng)

        let distance = userLocation.distance(from: placeLocation)

        if distance < 1000 {
            return "\(Int(distance)) metros"
        } else {
            let km = distance / 1000
            return "\(String(format: "%.1f", km)) km"
        }
    }

}

class MapCoordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    init(_ parent: MapView) {
        self.parent = parent
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let userAnnotation = annotation as? UserAnnotation {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: UserAnnotationView.reuseIdentifier) as? UserAnnotationView
            if view == nil { view = UserAnnotationView(annotation: userAnnotation, reuseIdentifier: UserAnnotationView.reuseIdentifier) }
            else { view?.annotation = userAnnotation }
            return view
        }
        if let placeAnnotation = annotation as? PlaceAnnotation {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: PlaceAnnotationView.reuseIdentifier) as? PlaceAnnotationView
            if view == nil { view = PlaceAnnotationView(annotation: placeAnnotation, reuseIdentifier: PlaceAnnotationView.reuseIdentifier) }
            else { view?.annotation = placeAnnotation }
            return view
        }
        if annotation is MKPointAnnotation && annotation.title == "Você" {
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "UserPin")
            view.markerTintColor = .systemBlue
            view.glyphText = "🟢"
            return view
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let userAnnotation = view.annotation as? UserAnnotation {
            NotificationCenter.default.post(
                name: Notification.Name("UserAnnotationTapped"),
                object: nil,
                userInfo: ["userModel": userAnnotation.userModel]
            )
        }
        if let placeAnnotation = view.annotation as? PlaceAnnotation {
            NotificationCenter.default.post(
                name: Notification.Name("PlaceAnnotationTapped"),
                object: nil,
                userInfo: ["location": placeAnnotation.location]
            )
        }
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
}
