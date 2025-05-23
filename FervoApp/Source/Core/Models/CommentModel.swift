//
//  CommentModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct Comment: Codable, Equatable {
    let user: UserModel
    let text: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case user
        case text
        case createdAt = "created_at"
    }
}
