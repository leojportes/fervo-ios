//
//  UserRequestModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//

struct UserRequestModel: Codable {
    let id: String
    let firebaseUid: String
    let email: String
    let username: String
    let name: String
    let image: ImageModel?
    let musicalTaste: [String]
    let age: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, email, username, name, image, age
        case firebaseUid = "firebase_uid"
        case musicalTaste = "musical_taste"
        case createdAt = "created_at"
    }
}

struct ImageModel: Codable {
    let imageId: String
    let photoURL: String?
}
