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
    @Binding var resetTrigger: Bool
    let users: [CheckinActiveUserResponse]?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.pointOfInterestFilter = .excludingAll
        mapView.overrideUserInterfaceStyle = .dark
        mapView.delegate = context.coordinator

        // Centraliza inicial
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: false)

        // Adiciona pin principal (local)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)

        // Adiciona usuários
        addUserAnnotations(to: mapView)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if resetTrigger {
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: true)

            DispatchQueue.main.async {
                resetTrigger = false
            }
        }

        // Atualiza usuários sempre que mudar
        uiView.removeAnnotations(uiView.annotations.filter { $0 is UserAnnotation })
        addUserAnnotations(to: uiView)
    }

    private func addUserAnnotations(to mapView: MKMapView) {
        if let users = self.users {
            let baseCoord = coordinate

            // Usa o span para calcular o "espaço" entre os usuários
            let baseRadius: Double = 5   // distância mínima em metros
            let zoomFactor = max(span.latitudeDelta, span.longitudeDelta)

            // quanto mais afastado o mapa, maior será o raio
            let radius: Double = baseRadius + (zoomFactor * 500) // 500 é um fator de escala// raio em metros para espalhar os usuários
            let count = users.count

            for (index, user) in users.enumerated() {
                // ângulo de cada usuário no círculo
                let angle = (2 * Double.pi / Double(count)) * Double(index)

                // deslocamento em metros (x = leste/oeste, y = norte/sul)
                let dx = radius * cos(angle)
                let dy = radius * sin(angle)

                // aplica offset na coordenada base
                let coord = baseCoord.offsetBy(latMeters: dy, lonMeters: dx)

                let annotation = UserAnnotation(
                    coordinate: coord,
                    imageURL: URL(string: user.user.image?.photoURL ?? ""),
                    userModel: user.user
                )
                mapView.addAnnotation(annotation)
            }
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Não substituir o pin central
            if annotation is MKPointAnnotation {
                return nil
            }

            if let userAnnotation = annotation as? UserAnnotation {
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: UserAnnotationView.reuseIdentifier) as? UserAnnotationView
                if view == nil {
                    view = UserAnnotationView(annotation: userAnnotation, reuseIdentifier: UserAnnotationView.reuseIdentifier)
                } else {
                    view?.annotation = userAnnotation
                }
                return view
            }
            return nil
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let userAnnotation = view.annotation as? UserAnnotation else { return }

            // Aqui você tem acesso ao firebase_uid
            let userModel = userAnnotation.userModel

            // Exemplo: mandar para uma função SwiftUI via NotificationCenter
            NotificationCenter.default.post(
                name: Notification.Name("UserAnnotationTapped"),
                object: nil,
                userInfo: ["userModel": userModel]
            )

            // Opcional: desseleciona para poder clicar de novo
            mapView.deselectAnnotation(view.annotation, animated: false)
        }

    }
}

struct MapContentView: View {
    @State private var selectedUser: UserModel?
    @State private var resetTrigger = false

    let initialCoordinate: CLLocationCoordinate2D
    let span: MKCoordinateSpan
    let users: [CheckinActiveUserResponse]?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                MapView(coordinate: initialCoordinate,
                        span: span,
                        resetTrigger: $resetTrigger,
                        users: users)
                .edgesIgnoringSafeArea(.all)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserAnnotationTapped"))) { notif in
                    if let user = notif.userInfo?["userModel"] as? UserModel {
                        selectedUser = user
                    }
                }

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
