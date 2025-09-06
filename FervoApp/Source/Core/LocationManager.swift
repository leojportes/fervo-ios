//
//  LocationManager.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 28/08/25.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var error: Error?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        requestAuthorization()
    }

    func requestAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            self.error = NSError(domain: "Location", code: 1, userInfo: [NSLocalizedDescriptionKey: "Localização não autorizada"])
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        currentLocation = location.coordinate
        // Não para de atualizar, mantém em tempo real
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }

    // Calcula distância entre o usuário e outro ponto (em metros)
    func distance(to latitude: Double, _ longitude: Double) -> Double? {
        guard let current = currentLocation else { return nil }
        let userLoc = CLLocation(latitude: current.latitude, longitude: current.longitude)
        let placeLoc = CLLocation(latitude: latitude, longitude: longitude)
        return userLoc.distance(from: placeLoc)
    }

    // Verifica se está dentro de uma distância específica
    func isWithinDistance(_ meters: Double, latitude: Double, longitude: Double) -> Bool {
        guard let distance = distance(to: latitude, longitude) else { return false }
        return distance <= meters
    }
}
