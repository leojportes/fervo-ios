//
//  UserSession.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

class UserSession: ObservableObject {
    @Published var isAuthenticated: Bool? = nil
    @Published var userProfileImage: Image? = nil
    @Published var currentUser: UserModel? {
        didSet {
            if let user = currentUser {
                print("✅ UserSession: Usuário atualizado: \(user.name)")
                loadUserProfileImage()
            }
        }
    }

    init() {
        loadFromUserDefaults()
        loadUserProfileImage()
    }

    func saveToUserDefaults() {
        guard let currentUser = currentUser else { return }
        FVUserDefault.setObject(currentUser, forKey: FVKeys.currentUser)
    }

    func loadFromUserDefaults() {
        currentUser = FVUserDefault.getObject(forKey: FVKeys.currentUser, type: UserModel.self)
    }

    func clear() {
        try? Auth.auth().signOut()
        FVUserDefault.remove(key: FVKeys.currentUser)
        self.isAuthenticated = false
        self.currentUser = nil
        self.userProfileImage = nil
        KeychainService.deleteCredentials()
    }

    func signOut(result: (Bool) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            clear()
            result(true)
        } catch {
            result(false)
        }
    }

    private func loadUserProfileImage() {
        guard let urlString = currentUser?.image?.photoURL,
              let url = URL(string: urlString) else {
            print("⚠️ Nenhuma URL de foto de perfil encontrada ou URL inválida")
            return
        }

        print("🔗 Buscando imagem de perfil em: \(urlString)")
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.userProfileImage = Image(uiImage: uiImage)
                    print("✅ Imagem de perfil carregada com sucesso")
                }
            } else {
                DispatchQueue.main.async {
                    print("❌ Falha ao carregar a imagem de perfil")
                    self.userProfileImage = nil
                }
            }
        }
    }
}
