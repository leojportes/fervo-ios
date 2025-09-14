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
    let fixedLocationId: String?
    let fixedLocation: FixedLocation? // Feed Profile view use
    let image: ImageModel
    let createdAt: Date
    let comments: [PostComment]?
    let likedUsers: [UserModel]?
    let likedBy: [String]?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firebaseId = "firebase_uid"
        case userPost = "user_post"
        case fixedLocationId = "fixed_location_id"
        case image
        case createdAt = "created_at"
        case comments
        case likedBy = "liked_by"
        case likedUsers = "liked_users"
        case fixedLocation = "fixed_location"
    }

    func hasMyLike(firebaseUid: String) -> Bool {
        if let likedUsers = likedUsers {
            return likedUsers.contains(where: {
                print($0.firebaseUid)
                print(firebaseUid)
                return $0.firebaseUid == firebaseUid
            })
        }
        return false
    }

    var likeDescription: String {
        guard let likedUsers = likedUsers else {
            return ""
        }
        let firstTwoUsers = likedUsers.prefix(2)

        // Criar a string com os nomes dos primeiros dois
        let names = firstTwoUsers.map { "@\($0.username)" }.joined(separator: ", ")

        // Se houver mais de dois usuários, adiciona "e outras pessoas"
        if likedUsers.count > 2 {
            return "Curtido por \(names) e outras pessoas."
        } else {
            return "Curtido por \(names)."
        }
    }
}
