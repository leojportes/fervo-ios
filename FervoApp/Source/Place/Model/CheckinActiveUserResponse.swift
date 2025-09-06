//
//  CheckinActiveUserResponse.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 24/08/25.
//

import Foundation

struct CheckinActiveUserResponse: Codable, Identifiable, Hashable {
    let id = UUID()
    let user: UserModel
    let minutesInPlace: Int

    enum CodingKeys: String, CodingKey {
        case user
        case minutesInPlace = "minutes_in_place"
    }
    
}
