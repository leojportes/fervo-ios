//
//  PlaceViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/08/25.
//

import SwiftUI
import Lottie

class PlaceViewModel: ObservableObject {
    @Published var price: Double = 0
    @Published var acceptedTerms: Bool = false
    @Published var musicalTaste: [String] = []
    @Published var crowdLevel: CrowdLevel = .medium
    @Published var activeUsers: [CheckinActiveUserResponse] = []

    @Published var isFetchingActiveUsers: Bool = false

    let firebaseUid: String

    init(firebaseUid: String) {
        self.firebaseUid = firebaseUid
    }

    var activeUsernames: String {
        let users = self.activeUsers
        let firstTwoUsers = users.prefix(2)

        // Criar a string com os nomes dos primeiros dois
        let names = firstTwoUsers.map { "@\($0.user.username)" }.joined(separator: ", ")

        // Se houver mais de dois usuários, adiciona "e outras pessoas"
        switch users.count {
        case 1: return "\(names) no rolê."
        case 2: return "\(names) no rolê."
        case 3: return "\(names)\ne outra pessoa."
        case 4: return "\(names)\ne outras 2 pessoas."
        default: return "\(names)\ne outras \(self.activeUsers.count - 2) pessoas."
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

    func makeCheckin(
        placeID: String,
        lat: Double,
        lng: Double,
        completion: @escaping (Bool) -> Void
    ) {
        let musicParam = musicalTaste.joined(separator: ",")

        guard var urlComponents = URLComponents(string: "http://localhost:8080/checkin") else {
            print("URL inválida")
            completion(false)
            return
        }

        // Query params
        urlComponents.queryItems = [
            URLQueryItem(name: "accepted_terms", value: acceptedTerms.description),
            URLQueryItem(name: "price", value: String(price)),
            URLQueryItem(name: "music_styles", value: musicParam),
            URLQueryItem(name: "crowd_status", value: crowdLevel.rawValue)
        ]

        guard let url = urlComponents.url else {
            print("Falha ao montar URL")
            completion(false)
            return
        }

        // Body JSON
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
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro ao fazer checkin:", error)
                DispatchQueue.main.async { completion(false) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Resposta inválida")
                DispatchQueue.main.async { completion(false) }
                return
            }

            if (200..<300).contains(httpResponse.statusCode) {
                print("✅ Check-in realizado com sucesso")
                DispatchQueue.main.async { completion(true) }
            } else {
                print("❌ Falha no check-in. Status code: \(httpResponse.statusCode)")
                if let data = data,
                   let errString = String(data: data, encoding: .utf8) {
                    print("Detalhe erro:", errString)
                }
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }

    func fetchActiveUsers(placeID: String) {
        self.isFetchingActiveUsers = true
        guard let url = URL(string: "http://localhost:8080/active-users?place_id=\(placeID)") else {
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
}

enum CrowdLevel: String, CaseIterable, Identifiable {
    case low, medium, hard
    var id: String { rawValue }

    var title: String {
        switch self {
        case .low: return "Pouco movimentado"
        case .medium: return "Movimentado"
        case .hard: return "Muito movimentado"
        }
    }

    private var lottieFilename: String {
        switch self {
        case .low: return "fire_icon"
        case .medium: return "fire_icon"
        case .hard: return "fire_icon"
        }
    }

    @ViewBuilder
    var emojiView: some View {
        VStack {
            switch self {
            case .low:
                HStack(spacing: 0) {
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                }
            case .medium:
                HStack(spacing: 0) {
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                }
            case .hard:
                HStack(spacing: 0) {
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                    LottieView(animationName: lottieFilename)
                        .frame(width: frameSize, height: frameSize)
                }
            }
        }.padding(.bottom, 10)
    }

    private var frameSize: CGFloat {
        switch self {
        case .low: return 26
        case .medium: return 26
        case .hard: return 26
        }
    }
}
