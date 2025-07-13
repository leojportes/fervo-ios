//
//  UserToConnect.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/05/25.
//

import Foundation

struct UserToConnect: Identifiable, Codable, Equatable {
    let id: String
    let firebaseUID: String
    let username: String
    let name: String
    let email: String
    let image: ImageModel
}
