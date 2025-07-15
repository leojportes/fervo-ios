import Foundation
import FirebaseAuth

final class LoginViewModel: ObservableObject {
    @Published var email: String = "leojportes@gmail.com"
    @Published var password: String = "12345678"
    @Published var isLoading: Bool = false
    @Published var isLoadingAuthState: Bool = true // 👈 novo estado para saber se está checando autoLogin
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserModel?

    private var alreadyCheckedAutoLogin = false // 👈 evita múltiplas execuções

    // MARK: - AutoLogin
    func autoLoginIfNeeded() {
        guard !alreadyCheckedAutoLogin else { return } // 👈 executa apenas uma vez
        alreadyCheckedAutoLogin = true

        print("🔄 [AutoLogin] Verificando se há usuário salvo no Firebase...")

        if let firebaseUser = Auth.auth().currentUser {
            print("✅ [AutoLogin] Usuário já autenticado: \(firebaseUser.email ?? "sem email")")
            fetchUserData(firebaseUID: firebaseUser.uid) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        self.currentUser = user
                        self.isAuthenticated = true
                        print("🎉 [AutoLogin] Usuário carregado: \(user.name)")
                    case .failure(let error):
                        print("❌ [AutoLogin] Falha ao buscar dados do usuário: \(error.localizedDescription)")
                        self.isAuthenticated = false
                    }
                    self.isLoadingAuthState = false
                }
            }
        } else {
            print("🚫 [AutoLogin] Nenhum usuário logado no Firebase")
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.isLoadingAuthState = false
            }
        }
    }

    // MARK: - Login
    func login(userSession: UserSession) {
        errorMessage = nil
        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error as NSError? {
                    self.mapFirebaseError(error)
                    return
                }

                guard let firebaseUID = result?.user.uid else {
                    self.errorMessage = "Usuário inválido"
                    self.isAuthenticated = false
                    return
                }

                self.fetchUserData(firebaseUID: firebaseUID) { fetchResult in
                    switch fetchResult {
                    case .success(let user):
                        print("✅ [Login] Usuário autenticado: \(user.name)")
                        KeychainService.saveCredentials(email: self.email, password: self.password)
                        userSession.currentUser = user
                        userSession.isAuthenticated = true
                        self.isAuthenticated = true
                    case .failure(let fetchError):
                        print("❌ [Login] Falha ao buscar dados do usuário: \(fetchError)")
                        self.errorMessage = fetchError.localizedDescription
                        self.isAuthenticated = false
                    }
                }
            }
        }
    }

    // MARK: - Fetch User
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
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    let emptyDataError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dados vazios da API."])
                    completion(.failure(emptyDataError))
                    return
                }

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 JSON recebido:\n\(jsonString)")
                }

                do {
                    let user = try JSONDecoder().decode(UserModel.self, from: data)
                    FVUserDefault.setObject(user, forKey: FVKeys.currentUser)
                    completion(.success(user))
                } catch {
                    print("❌ Erro ao decodificar: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Erro Firebase
    private func mapFirebaseError(_ error: NSError) {
        if let message = error.userInfo[NSLocalizedDescriptionKey] as? String {
            self.errorMessage = self.descriptionError(error: message)
        } else {
            self.errorMessage = "Erro inesperado: \(error.localizedDescription)"
        }
        self.isAuthenticated = false
    }

    private func descriptionError(error: String) -> String {
        switch error {
        case "INVALID_LOGIN_CREDENTIALS":
            return "Email e/ou senha incorretos."
        default:
            return "Ocorreu um erro inesperado. Tente novamente mais tarde."
        }
    }
}

let baseIPForTest = "localhost"
