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

    // Binding para disparar reset
    @Binding var resetTrigger: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.pointOfInterestFilter = .excludingAll
        mapView.overrideUserInterfaceStyle = .dark

        // Centraliza inicial
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)

        // Adiciona pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if resetTrigger {
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: true)

            // reseta trigger
            DispatchQueue.main.async {
                resetTrigger = false
            }
        }
    }
}

struct MapContentView: View {
    @State private var resetTrigger = false

    // Exemplo: coordenada de Floripa
    let initialCoordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MapView(coordinate: initialCoordinate, span: span, resetTrigger: $resetTrigger)
                .edgesIgnoringSafeArea(.all)

            Button(action: {
                resetTrigger = true
            }) {
                Image(systemName: "scope")
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                
            }
            .padding()
        }
    }
}
