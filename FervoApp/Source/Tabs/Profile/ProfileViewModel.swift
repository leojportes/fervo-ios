//
//  ProfileViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/07/25.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

final class ProfileViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var connectedUsers: [UserModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hasConnection: Bool = false
    @Published var hasPendingConnections: Bool = false
    @Published var pendingConnectionId: String? = nil
    @Published var isLoadingCheckConnection: Bool = false
    @Published var isLoadingCheckRequestConnection: Bool = true
    @Published var userActivityHistory: [UserActivityResponse] = []
    @Published var isFetchingHistory: Bool = false
    @Published var pendingConnections: [PendingConnection] = []


    private var cancellables = Set<AnyCancellable>()
    private var isFetching: Bool = false
    private var isFetchingConnectedUsers = false
    
    enum ConnectionButtonStatus {
        case connect         /// nenhuma conexão
        case pendingSent     /// logado enviou
        case pendingReceived /// outro usuário enviou
        case connected       /// já são amigos/conectados
    }

    func getConnectionButtonStatus(
        loggedUserId: String,
        profileUserId: String,
        connections: [PendingConnection]
    ) -> ConnectionButtonStatus {
        // tenta encontrar uma conexão entre logado e perfil
        if let conn = connections.first(where: { 
            ($0.from.firebaseUid == loggedUserId && $0.to.firebaseUid == profileUserId) ||
            ($0.from.firebaseUid == profileUserId && $0.to.firebaseUid == loggedUserId)
        }) {
            switch conn.status {
            case "pending":
                if conn.from.firebaseUid == loggedUserId {
                    return .pendingSent
                } else {
                    return .pendingReceived
                }
            case "accepted":
                return .connected
            default:
                return .connect
            }
        }
        
        return .connect
    }

    // MARK: - Computed Properties
    var totalRoles: Int {
        return userActivityHistory.count
    }
    
    
    var userLevel: String {
        if totalRoles < 40 {
            return "Rolezeiro(a)\nIniciante"
        } else if totalRoles < 100 {
            return "Rolezeiro(a)\nExplorador"
        } else {
            return "Rolezeiro(a)\nVeterano"
        }
    }
    
    var levelColor: Color {
        if totalRoles < 40 {
            return Color(red: 212/255, green: 175/255, blue: 55/255)
        } else if totalRoles < 100 {
            return Color(red: 212/255, green: 175/255, blue: 55/255)
        } else {
            return .purple
        }
    }
    
    var isMaxLevel: Bool {
        return totalRoles >= 100
    }
    
    var nextLevelThreshold: Int {
        if totalRoles < 40 {
            return 40
        } else if totalRoles < 100 {
            return 100
        } else {
            return 100 // Nível máximo
        }
    }
    
    var progressToNextLevel: Double {
        if totalRoles < 40 {
            return Double(totalRoles) / 40.0
        } else if totalRoles < 100 {
            return Double(totalRoles - 40) / 60.0 // De 40 até 100 (60 rolês de diferença)
        } else {
            return 1.0 // Nível máximo atingido
        }
    }
    
    var mostFrequentedPlaceThisMonth: (location: FixedLocation, count: Int)? {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        // Filtrar atividades do último mês
        let recentActivities = userActivityHistory.filter { activity in
            guard let checkInDate = activity.checkInDate else { return false }
            return checkInDate >= oneMonthAgo
        }
        
        // Contar frequência por local
        var locationCounts: [String: (location: FixedLocation, count: Int)] = [:]
        
        for activity in recentActivities {
            let location = activity.fixedlocation.fixedLocation
            let locationId = location.id
            
            if let existing = locationCounts[locationId] {
                locationCounts[locationId] = (location: location, count: existing.count + 1)
            } else {
                locationCounts[locationId] = (location: location, count: 1)
            }
        }
        
        // Retornar o local mais frequentado
        return locationCounts.values.max { $0.count < $1.count }
    }

    var numberOfonnectionsTitle: String {
        connectedUsers.count == 1 ? "Conexão" : "Conexões"
    }


    func fetchUserPosts(firebaseUID: String) {
        guard !isFetching else { return }  // evita chamadas concorrentes
        isFetching = true
        isLoading = true

        Auth.auth().currentUser?.getIDToken { [weak self] token, error in
            guard let self = self else { return }
            defer { self.isFetching = false }  // libera a flag ao final da execução

            if let error = error {
                self.errorMessage = "Erro ao obter token: \(error.localizedDescription)"
                self.isLoading = false
                return
            }

            guard let token = token else {
                self.errorMessage = "Token inválido"
                self.isLoading = false
                return
            }

            self.performRequest(firebaseUID: firebaseUID, token: token)
        }
    }

    private func performRequest(firebaseUID: String, token: String) {
        guard var components = URLComponents(string: "\(baseIPForTest)/posts/by-user") else {
            self.errorMessage = "URL inválida"
            self.isLoading = false
            return
        }

        components.queryItems = [URLQueryItem(name: "firebase_uid", value: firebaseUID)]

        guard let url = components.url else {
            self.errorMessage = "URL inválida com query"
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveOutput: { output in
                if let jsonString = String(data: output.data, encoding: .utf8) {
                    print("🔵 JSON bruto recebido: \(jsonString)")
                }
            })
            .map(\.data)
            .decode(type: [Post].self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] posts in
                self?.posts = posts
            }
            .store(in: &cancellables)
    }

    func checkConnection(with otherUserUID: String, completion: ((Bool) -> Void)? = nil) {
        self.isLoadingCheckConnection = true
        guard Auth.auth().currentUser?.uid != nil else {
            self.hasConnection = false
            completion?(false)
            return
        }

        let urlString = "\(baseIPForTest)/connections/check/\(otherUserUID)"
        guard let url = URL(string: urlString) else {
            print("URL inválida: \(urlString)")
            self.hasConnection = false
            self.isLoadingCheckConnection = false
            completion?(false)
            return
        }

        Auth.auth().currentUser?.getIDToken { [weak self] token, error in
            guard let self = self else { return }
            if let error = error {
                print("Erro ao pegar token: \(error.localizedDescription)")
                self.hasConnection = false
                self.isLoadingCheckConnection = false
                completion?(false)
                return
            }

            guard let token = token else {
                print("Token é nulo")
                self.hasConnection = false
                completion?(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalCacheData

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Erro na requisição: \(error.localizedDescription)")
                        self.hasConnection = false
                        self.isLoadingCheckConnection = false
                        completion?(false)
                        return
                    }

                    guard let data = data else {
                        print("Resposta sem dados")
                        self.isLoadingCheckConnection = false
                        self.hasConnection = false
                        completion?(false)
                        return
                    }

                    do {
                        // Decodifica JSON e extrai campo connected
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let connected = json?["connected"] as? Bool ?? false
                        self.isLoadingCheckConnection = false
                        self.hasConnection = connected
                        completion?(connected)
                    } catch {
                        print("Erro ao decodificar JSON: \(error.localizedDescription)")
                        self.isLoadingCheckConnection = false
                        self.hasConnection = false
                        completion?(false)
                    }
                }
            }.resume()
        }
    }

    func fetchPendingConnections(userIdToCheck: String) {
        self.isLoadingCheckRequestConnection = true
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                print("[❌] Erro ao obter token: \(error)")
                self.isLoadingCheckRequestConnection = false
                return
            }

            guard let token = token else {
                print("[❌] Token inválido")
                self.isLoadingCheckRequestConnection = false
                return
            }

            self.performFetchPendingConnections(token: token, userIdToCheck: userIdToCheck)
        }
    }

    private func performFetchPendingConnections(token: String, userIdToCheck: String) {
        guard let url = URL(string: "\(baseIPForTest)/connections/pending") else {
            print("[❌] URL inválida")
            self.isLoadingCheckRequestConnection = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                if response.statusCode == 200 {
                    return result.data
                } else {
                    // Tentar extrair mensagem de erro do corpo
                    if let errorResponse = try? JSONSerialization.jsonObject(with: result.data, options: []) as? [String: Any],
                       let message = errorResponse["message"] as? String {
                        throw NSError(domain: "APIError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
                    } else {
                        throw NSError(domain: "APIError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Status code \(response.statusCode)"])
                    }
                }
            }
            .decode(type: [PendingConnection].self, decoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return decoder
            }())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.isLoadingCheckRequestConnection = false
                    print("[❌] Falha ao buscar pendentes: \(error.localizedDescription)")
                case .finished:
                    self.isLoadingCheckRequestConnection = false
                    print("[✅] Conexões pendentes carregadas")
                }
            } receiveValue: { [weak self] connections in
                self?.pendingConnections = connections
                self?.hasPendingConnections = !connections.filter({ $0.from.firebaseUid == userIdToCheck && $0.status == "pending" }).isEmpty
                self?.pendingConnectionId = connections
                    .first(where: { $0.from.firebaseUid == userIdToCheck && $0.status == "pending" })?.id
                self?.isLoadingCheckRequestConnection = false
            }
            .store(in: &cancellables)
    }

    func acceptConnection(connectionID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performAcceptConnection(connectionID: connectionID, token: token, completion: completion)
        }
    }

    private func performAcceptConnection(connectionID: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseIPForTest)/connections/\(connectionID)/accept") else {
            completion(.failure(NSError(domain: "URL inválida", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Resposta inválida", code: -2)))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    self.hasConnection = true
                    completion(.success(()))
                }
            } else {
                completion(.failure(NSError(domain: "Erro ao aceitar conexão. Status: \(httpResponse.statusCode)", code: httpResponse.statusCode)))
            }
        }.resume()
    }

    func fetchConnectedUsers(for uid: String? = nil) {
        guard !isFetchingConnectedUsers else { return }
        isFetchingConnectedUsers = true

        Auth.auth().currentUser?.getIDToken { [weak self] token, error in
            guard let self = self else { return }
            defer { self.isFetchingConnectedUsers = false }

            if let error = error {
                print("Erro ao obter token: \(error.localizedDescription)")
                return
            }

            guard let token = token else {
                print("Token inválido")
                return
            }

            // Monta a URL dependendo se passou UID ou não
            let urlString: String
            if let uid = uid, !uid.isEmpty {
                // Buscar conexões de outro usuário
                urlString = "\(baseIPForTest)/connections/connected/uuid?uid=\(uid)"
            } else {
                // Buscar conexões do usuário logado
                urlString = "\(baseIPForTest)/connections/connected"
            }

            guard let url = URL(string: urlString) else {
                print("URL inválida")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.cachePolicy = .reloadIgnoringLocalCacheData

            let decoder = JSONDecoder()
            // decoder.dateDecodingStrategy = .iso8601 // se precisar para datas

            URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: [UserModel].self, decoder: decoder)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case let .failure(error) = completion {
                        print("Erro ao buscar usuários conectados: \(error.localizedDescription)")
                    }
                } receiveValue: { [weak self] users in
                    self?.connectedUsers = users
                }
                .store(in: &self.cancellables)
        }
    }

    func fetchUserActivityHistory(uid: String) {
        guard let url = URL(string: "\(baseIPForTest)/checkin/history?firebase_uid=\(uid)") else {
            print("URL inválida")
            self.isFetchingHistory = false
            return
        }

        self.isFetchingHistory = true

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print("Erro ao buscar histórico:", error)
                self.isFetchingHistory = false
                return
            }

            guard let data = data else {
                print("Nenhum dado retornado")
                self.isFetchingHistory = false
                return
            }

            do {

                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSZ"

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(formatter)


                let activities = try decoder.decode([UserActivityResponse].self, from: data)

                DispatchQueue.main.async {
                    self.isFetchingHistory = false
                    self.userActivityHistory = activities
                }
            } catch {
                print("Erro ao decodificar JSON:", error)
            }
        }.resume()
    }
    
    func requestConnection(toUserID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let token = token else {
                completion(.failure(NSError(domain: "Token inválido", code: -1)))
                return
            }

            self.performRequestConnection(toUserID: toUserID, token: token, completion: completion)
        }
    }

    private func performRequestConnection(toUserID: String, token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseIPForTest)/connections/request") else {
            completion(.failure(NSError(domain: "URL inválida", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Criar o body da requisição
        let requestBody = ["to": toUserID]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(NSError(domain: "Erro ao serializar JSON", code: -3)))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Resposta inválida", code: -2)))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } else {
                completion(.failure(NSError(domain: "Erro ao solicitar conexão. Status: \(httpResponse.statusCode)", code: httpResponse.statusCode)))
            }
        }.resume()
    }
}
