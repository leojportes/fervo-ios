//
//  TransporteDarkButton.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 28/08/25.
//

import SwiftUI

struct TransportDarkButton: View {
    enum Service {
        case uber
        case google
    }

    enum Destination {
        case address(_ text: String)
        case coordinates(lat: Double, lng: Double, name: String? = nil)
    }

    enum Style {
        case dark
        case light
    }

    let service: Service
    let destination: Destination
    let style: Style

    @Environment(\.colorScheme) private var scheme
    @State private var isPressed = false

    var body: some View {
        Button(action: openDestination) {
            HStack(spacing: 8) {
                Image(service == .uber ? "uber" : "map")
                    .renderingMode(style == .dark ? .template : .original)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)

                Text(service == .uber ? "Uber" : "Maps")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .foregroundStyle(Color.white)
            .background(
                (isPressed ? Color.black.opacity(0.75) : Color.black.opacity(0.92))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .animation(.easeOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("Abrir destino no \(service == .uber ? "Uber" : "Google Maps")")
    }

    private func openDestination() {
        func encode(_ s: String) -> String {
            s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
        }

        var appURL: URL?
        var webURL: URL?

        switch (service, destination) {
        case (.uber, .address(let text)):
            let q = encode(text)
            appURL = URL(string: "uber://?action=setPickup&dropoff[formatted_address]=\(q)")
            webURL = URL(string: "https://m.uber.com/ul/?action=setPickup&dropoff[formatted_address]=\(q)")

        case (.uber, .coordinates(let lat, let lng, let name)):
            let nameEncoded = encode(name ?? "Destino")
            appURL = URL(string:
                            "uber://?action=setPickup&dropoff[latitude]=\(lat)&dropoff[longitude]=\(lng)&dropoff[nickname]=\(nameEncoded)"
            )
            webURL = URL(string:
                            "https://m.uber.com/ul/?action=setPickup&dropoff[latitude]=\(lat)&dropoff[longitude]=\(lng)&dropoff[nickname]=\(nameEncoded)"
            )

        case (.google, .address(let text)):
            let q = encode(text)
            appURL = URL(string: "comgooglemaps://?q=\(q)")
            webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(q)")

        case (.google, .coordinates(let lat, let lng, let name)):
            let nameEncoded = encode(name ?? "")
            appURL = URL(string: "comgooglemaps://?q=\(lat),\(lng)(\(nameEncoded))&center=\(lat),\(lng)&zoom=16")
            webURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(lat),\(lng)")
        }

        if let appURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL {
            UIApplication.shared.open(webURL)
        }
    }
}
