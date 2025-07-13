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
            //saveToUserDefaults()
            loadUserProfileImage()
        }
    }

    init() {
        //loadFromUserDefaults()
        loadUserProfileImage()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
          //  self.autoLogin()
        }
    }

    func saveToUserDefaults() {
        guard let currentUser = currentUser else { return }
        FVUserDefault.setObject(currentUser, forKey: FVKeys.currentUser)
    }

    func loadFromUserDefaults() {
        currentUser = FVUserDefault.getObject(forKey: FVKeys.currentUser, type: UserModel.self)
    }

    func clear() {
        currentUser = nil
        FVUserDefault.remove(key: FVKeys.currentUser)
    }

    func autoLogin() {
        let data = KeychainService.loadCredentials()
        guard KeychainService.verifyIfExists(),
              let email = data.first,
              let password = data.last else {
            isAuthenticated = false
            return
        }

        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { _, error in
            DispatchQueue.main.async {
                self.isAuthenticated = error == nil
            }
        }
    }

    func loadUserProfileImage() {
        guard let urlString = currentUser?.image?.photoURL,
              let url = URL(string: urlString) else {
            userProfileImage = nil
            return
        }

        // Carrega a imagem de forma assíncrona
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                let image = Image(uiImage: uiImage)
                DispatchQueue.main.async {
                    self.userProfileImage = image
                }
            }
        }
    }
}
