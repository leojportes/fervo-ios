//
//  MapView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/07/25.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()

        mapView.pointOfInterestFilter = .excludingAll

        // Centraliza o mapa
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)

        // Adiciona pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.overrideUserInterfaceStyle = .dark

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Nada necessário aqui no seu caso
    }
}
