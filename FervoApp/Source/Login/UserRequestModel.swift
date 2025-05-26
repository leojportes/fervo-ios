//
//  UserRequestModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//

struct UserModel: Codable, Equatable, Hashable {
    let firebaseUid: String
    let email: String
    let username: String
    let name: String
    let image: ImageModel?
    let musicalTaste: [String]?
    let age: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case email, username, name, image, age
        case firebaseUid = "firebase_uid"
        case musicalTaste = "musical_taste"
        case createdAt = "created_at"
    }
}

struct ImageModel: Codable, Equatable, Hashable {
    let imageId: String?
    let photoURL: String?

    enum CodingKeys: String, CodingKey {
        case photoURL = "photo_url"
        case imageId = "image_id"
    }
}
