//
//  ConnectionsModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct ConnectionsModel: Decodable, Equatable {
    let from: String
    let to: String
    let status: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case from
        case to
        case status
        case createdAt = "created_at"
    }
}
