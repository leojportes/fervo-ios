//
//  LocationWithPostsModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct LocationWithPosts: Identifiable, Decodable, Equatable, Hashable {
    var id: String {
        return "\(fixedLocation.name)-\(fixedLocation.city)"
    }

    let fixedLocation: FixedLocation
    let posts: [Post]

    enum CodingKeys: String, CodingKey {
        case fixedLocation = "fixedlocation"
        case posts
    }

    var lastThreePosts: [Post] {
        let posts = posts
            .sorted(by: { $0.createdAt > $1.createdAt })
            .prefix(3)
            .sorted(by: { $0.createdAt > $1.createdAt })
        return posts
    }

    var todayOpeningHours: String {
        guard let weekDays = fixedLocation.weekdayText else { return "" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE"
        let today = formatter.string(from: Date()).lowercased()

        if let todayLine = weekDays.first(where: { $0.lowercased().hasPrefix(today) }) {
            // Separa apenas na primeira ocorrência de ":"
            if let range = todayLine.range(of: ":") {
                let timePart = todayLine[range.upperBound...].trimmingCharacters(in: .whitespaces)
                return timePart
            }
        }

        return ""
    }

    var placeIsOpen: Bool {
        guard let weekDays = fixedLocation.weekdayText else { return false }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEEE"

        let now = Date()
        let calendar = Calendar.current
        let today = formatter.string(from: now).lowercased()
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: now)!
        let yesterday = formatter.string(from: yesterdayDate).lowercased()

        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTotalMinutes = currentHour * 60 + currentMinute

        func parseTimeRange(for day: String) -> (open: Int, close: Int)? {
            guard let dayLine = weekDays.first(where: { $0.lowercased().hasPrefix(day) }),
                  !dayLine.lowercased().contains("fechado") else { return nil }

            let timeRange = dayLine.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            let times = timeRange.components(separatedBy: "–")
            guard times.count == 2 else { return nil }

            let openingTimeString = times[0].trimmingCharacters(in: .whitespaces)
            let closingTimeString = times[1].trimmingCharacters(in: .whitespaces)

            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "pt_BR")
            timeFormatter.dateFormat = "HH:mm"

            guard let openingTime = timeFormatter.date(from: openingTimeString),
                  let closingTime = timeFormatter.date(from: closingTimeString) else {
                return nil
            }

            let openHour = calendar.component(.hour, from: openingTime)
            let openMinute = calendar.component(.minute, from: openingTime)
            let closeHour = calendar.component(.hour, from: closingTime)
            let closeMinute = calendar.component(.minute, from: closingTime)

            let openTotalMinutes = openHour * 60 + openMinute
            let closeTotalMinutes = closeHour * 60 + closeMinute

            return (open: openTotalMinutes, close: closeTotalMinutes)
        }

        // 1️⃣ Verifica se ainda estamos no horário do dia anterior que passou da meia-noite
        if let yesterdayRange = parseTimeRange(for: yesterday),
           yesterdayRange.open > yesterdayRange.close { // horário cruza a meia-noite
            if currentTotalMinutes < yesterdayRange.close {
                return true
            }
        }

        // 2️⃣ Verifica se hoje está dentro do horário de hoje
        if let todayRange = parseTimeRange(for: today) {
            if todayRange.open < todayRange.close {
                // Horário normal (ex.: 08:00–18:00)
                if currentTotalMinutes >= todayRange.open && currentTotalMinutes < todayRange.close {
                    return true
                }
            } else {
                // Horário passa da meia-noite (ex.: 21:00–04:00)
                if currentTotalMinutes >= todayRange.open {
                    // Hoje já passou da hora de abrir
                    return true
                }
                // Senão ainda não abriu
            }
        }

        return false
    }

}

struct Coordinates: Codable, Equatable, Hashable {
    let lat: Double
    let lng: Double
}


