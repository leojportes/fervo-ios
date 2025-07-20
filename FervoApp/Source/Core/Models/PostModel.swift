//
//  PostModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct Post: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let firebaseId: String
    let userPost: UserModel
    let fixedLocationId: String
    let image: ImageModel
    let createdAt: Date
    let likes: Int
    let comments: [PostComment]?
    let likedBy: [UserModel]

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firebaseId = "firebase_uid"
        case userPost = "user_post"
        case fixedLocationId = "fixed_location_id"
        case image
        case createdAt = "created_at"
        case likes
        case comments
        case likedBy = "liked_by"
    }

    var hasMyLike: Bool {
        return likedBy.contains(where: { $0.firebaseUid == "my firebaseUid" })
    }

    var likeDescription: String {
        let firstTwoUsers = likedBy.prefix(2)

        // Criar a string com os nomes dos primeiros dois
        let names = firstTwoUsers.map { "@\($0.username)" }.joined(separator: ", ")

        // Se houver mais de dois usuários, adiciona "e outras pessoas"
        if likedBy.count > 2 {
            return "Curtido por \(names) e outras pessoas."
        } else {
            return "Curtido por \(names)."
        }
    }
}
