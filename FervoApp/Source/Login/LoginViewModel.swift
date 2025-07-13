//
//  LoginViewModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//

import Foundation
import FirebaseAuth

final class LoginViewModel: ObservableObject {
    @Published var email: String = "leojportes@gmail.com"
    @Published var password: String = "12345678"
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserModel?


    func login() {
        errorMessage = nil
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.isLoading = false

                if let maybeError = error {
                    let err = maybeError as NSError
                    switch err.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        strongSelf.errorMessage = "Formato de email inválido."
                        strongSelf.isAuthenticated = false
                        return
                    default:
                        if let typeError = error as? NSError {
                            strongSelf.mapFirebaseError(typeError)
                            return
                        }
                    }
                }

                if let typeError = error as? NSError {
                    strongSelf.mapFirebaseError(typeError)
                    return
                }

                if let firebaseUID = result?.user.uid {
                    self?.fetchUserData(firebaseUID: firebaseUID) { result in
                        switch result {
                        case .success(let user):
                            FVUserDefault.set(value: true, forKey: FVKeys.authenticated)
                            KeychainService.saveCredentials(email: strongSelf.email, password: strongSelf.password)
                            guard let email = Auth.auth().currentUser?.email else { return }
                            FVUserDefault.set(value: true, forKey: email)
                            strongSelf.isAuthenticated = true
                        case .failure(let error):
                            print("❌ Falha ao carregar usuário: \(error.localizedDescription)")
                            strongSelf.isAuthenticated = false
                        }
                    }
                } else {
                    strongSelf.isAuthenticated = false
                    strongSelf.errorMessage = "Ocorreu um erro inesperado.\nPor favor, tente novamente mais tarde."
                }
            }
        }
    }

    private func fetchUserData(firebaseUID: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard let url = URL(string: "http://\(baseIPForTest):8080/users/firebase/\(firebaseUID)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida."])))
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Erro de rede: \(error.localizedDescription)"
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    let emptyDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dados vazios da API."])
                    self?.errorMessage = emptyDataError.localizedDescription
                    completion(.failure(emptyDataError))
                    return
                }

                // Debug JSON bruto
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🟢 JSON recebido da API:\n\(jsonString)")
                }

                do {
                    let user = try JSONDecoder().decode(UserModel.self, from: data)
                    self?.currentUser = user
                    FVUserDefault.setObject(user, forKey: FVKeys.currentUser)

                    completion(.success(user))
                } catch {
                    self?.errorMessage = "Erro ao decodificar os dados do usuário."
                    print("❌ Erro de decodificação: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    private func mapFirebaseError(_ error: NSError) {
        if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError,
           let deserialized = underlyingError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any],
           let message = deserialized["message"] as? String {

            self.errorMessage = self.descriptionError(error: message)
            self.isAuthenticated = false
        }
    }

    private func descriptionError(error: String) -> String {
        var description: String = ""

        switch error {
        case "INVALID_LOGIN_CREDENTIALS":
            description = "Email e/ou senha informados estão incorretos."
        default:
            description = "Ocorreu um erro inesperado.\nPor favor, tente novamente mais tarde."
        }

        return description
    }
}

let baseIPForTest = "localhost"
