//
//  PlaceViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/08/25.
//

import SwiftUI
import Lottie
import CoreLocation

class PlaceViewModel: ObservableObject {
    @Published var price: Double = 0
    @Published var acceptedTerms: Bool = false
    @Published var musicalTaste: [String] = []
    @Published var crowdLevel: CrowdLevel = .medium
    @Published var activeUsers: [CheckinActiveUserResponse] = []
    @Published var errorTooFar: String?
    @Published var isFetchingActiveUsers: Bool = false

    let firebaseUid: String

    init(firebaseUid: String) {
        self.firebaseUid = firebaseUid
    }

    func makeCheckin(
        placeID: String,
        lat: Double,
        lng: Double,
        completion: @escaping (CheckinResult) -> Void
    ) {
        let musicParam = musicalTaste.joined(separator: ",")

        guard var urlComponents = URLComponents(string: "\(baseIPForTest)/checkin") else {
            print("URL inválida")
            completion(.failure)
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "accepted_terms", value: acceptedTerms.description),
            URLQueryItem(name: "price", value: String(price)),
            URLQueryItem(name: "music_styles", value: musicParam),
            URLQueryItem(name: "crowd_status", value: crowdLevel.rawValue)
        ]

        guard let url = urlComponents.url else {
            print("Falha ao montar URL")
            completion(.failure)
            return
        }

        let body: [String: Any] = [
            "firebase_uid": firebaseUid,
            "place_id": placeID,
            "lat": lat,
            "lng": lng
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Erro ao montar body JSON:", error)
            completion(.failure)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro ao fazer checkin:", error)
                DispatchQueue.main.async { completion(.failure) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Resposta inválida")
                DispatchQueue.main.async { completion(.failure) }
                return
            }

            if (200..<300).contains(httpResponse.statusCode),
               let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let status = json["status"] as? String {

                        switch status {
                        case "checked_in":
                            print("✅ Check-in realizado com sucesso")
                            DispatchQueue.main.async { completion(.success) }
                        case "too_far_to_checkin":
                            print("⚠️ Usuário está muito longe para check-in")
                            DispatchQueue.main.async { completion(.tooFar) }
                        case "already_checked_in":
                            print("⚠️ Usuário está muito longe para check-in")
                            DispatchQueue.main.async { completion(.alreadyCheckedIn) }

                        default:
                            print("❌ Status desconhecido: \(status)")
                            DispatchQueue.main.async { completion(.failure) }
                        }
                    } else {
                        print("JSON inválido")
                        DispatchQueue.main.async { completion(.failure) }
                    }
                } catch {
                    print("Erro ao decodificar JSON:", error)
                    DispatchQueue.main.async { completion(.failure) }
                }
            } else {
                print("❌ Falha no check-in. Status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async { completion(.failure) }
            }
        }.resume()
    }

    func fetchActiveUsers(placeID: String) {
        self.isFetchingActiveUsers = true
        guard let url = URL(string: "\(baseIPForTest)/active-users?place_id=\(placeID)") else {
            print("URL inválida")
            self.isFetchingActiveUsers = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erro ao buscar usuários ativos:", error)
                self.isFetchingActiveUsers = false
                return
            }

            guard let data = data else {
                print("Nenhum dado retornado")
                self.isFetchingActiveUsers = false
                return
            }

            do {
                let users = try JSONDecoder().decode([CheckinActiveUserResponse].self, from: data)
                DispatchQueue.main.async {
                    self.activeUsers = users
                    self.isFetchingActiveUsers = false
                }
            } catch {
                print("Erro ao decodificar JSON:", error)
                self.isFetchingActiveUsers = false
            }
        }.resume()
    }

    var activeUsernames: String {
        let users = self.activeUsers
        let firstTwoUsers = users.prefix(2)
        let names = firstTwoUsers.map { "@\($0.user.username)" }.joined(separator: ", ")
        switch users.count {
        case 1: return "\(names) no rolê."
        case 2: return "\(names) no rolê."
        case 3: return "\(names)\ne outra pessoa."
        case 4: return "\(names)\ne outras 2 pessoas."
        case 5...:
            return "\(names)\ne outras \(self.activeUsers.count - 2) pessoas."
        default:
            return ""
        }
    }

    var peoplesNowDescription: String {
        switch activeUsers.count {
        case 0: return "0 pessoas agora"
        case 1: return "1 pessoa agora"
        default: return "\(activeUsers.count) pessoas agora"
        }
    }

    func currentUserHasActiveCheckin(firebaseUid currentUserFirebaseId: String) -> Bool {
        activeUsers.filter { $0.user.firebaseUid == currentUserFirebaseId }.count != 0
    }

    func isWithin10Meters(userLat: Double, userLng: Double, placeLat: Double, placeLng: Double) -> Bool {
        let userLocation = CLLocation(latitude: userLat, longitude: userLng)
        let placeLocation = CLLocation(latitude: placeLat, longitude: placeLng)

        let distance = userLocation.distance(from: placeLocation)

        return distance <= 10
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
