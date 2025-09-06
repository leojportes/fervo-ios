//
//  UserActivityModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 30/08/25.
//

import Foundation

struct UserActivityResponse: Decodable, Equatable, Hashable, Identifiable {
    var id: UUID = .init()

    let fixedlocation: LocationWithPosts
    let checkedInAt: String
    let checkedOutAt: String?
    let crowdStatus: String

    enum CodingKeys: String, CodingKey {
        case fixedlocation
        case checkedInAt = "checked_in_at"
        case checkedOutAt = "checked_out_at"
        case crowdStatus = "crowd_status"
    }
    
    var crowdStatusDescription: String {
        switch crowdStatus {
        case "1":
            return "• Estava pouco movimentado"
        case "2":
            return "• Estava movimentado"
        case "3":
            return "• Estava bastante movimentado"
        default:
            return ""
        }
    }

    var checkInDate: Date? { checkedInAt.asDate }
    var checkOutDate: Date? { checkedOutAt?.asDate }

    /// Retorna a duração em segundos
    var duration: TimeInterval? {
        guard let checkIn = checkInDate else { return nil }
        if let checkOut = checkOutDate {
            return checkOut.timeIntervalSince(checkIn)
        } else {
            return Date().timeIntervalSince(checkIn)
        }
    }

    /// Exibe a duração formatada (ex: "1h 23min")
    var formattedDuration: String {
        guard let duration else { return "--" }
        let minutes = Int(duration / 60) % 60
        let hours = Int(duration / 3600)
        if hours > 0 {
            return "• Curtiu por \(hours)h \(minutes)min"
        } else {
            return "• Curtiu por \(minutes)min"
        }
    }
}
