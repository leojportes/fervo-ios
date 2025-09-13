//
//  SearchPeopleModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 08/09/25.
//

import Foundation 

struct SearchPeopleModel: Decodable, Hashable, Equatable {
    let user: UserModel
    let connectionStatus: ConnectionStatus
    
    enum CodingKeys: String, CodingKey {
        case connectionStatus
        case user
    }
}

enum ConnectionStatus: String, Decodable, Hashable, Equatable {
    case notConnection = "not_connection"
    case pending
    case accepted
}
