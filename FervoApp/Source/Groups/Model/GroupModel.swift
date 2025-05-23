//
//  GroupModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct GroupModel: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let image: ImageModel
    let creator: String
    let users: [String]
    let createdAt: Date
    let isPrivate: Bool

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case createdAt = "create_at"
        case image
        case creator
        case users
        case name
        case isPrivate = "is_private"
    }
}
