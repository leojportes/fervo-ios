//
//  LocationWithPostsModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct LocationWithPosts: Identifiable, Decodable, Equatable {
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
        let today = formatter.string(from: Date()).lowercased()

        // 2. Encontramos a string correspondente ao dia atual
        guard let todayLine = weekDays.first(where: { $0.lowercased().hasPrefix(today) }) else {
            return false
        }

        // 3. Verificamos se está "Fechado"
        if todayLine.lowercased().contains("fechado") {
            return false
        }

        // 4. Extraímos os horários de abertura e fechamento
        let timeRange = todayLine.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
        let times = timeRange.components(separatedBy: "–")

        guard times.count == 2 else {
            return false
        }

        let openingTimeString = times[0].trimmingCharacters(in: .whitespaces)
        let closingTimeString = times[1].trimmingCharacters(in: .whitespaces)

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "pt_BR")
        timeFormatter.dateFormat = "HH:mm"

        // 5. Pegamos a hora atual
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)

        guard let openingTime = timeFormatter.date(from: openingTimeString),
              let closingTime = timeFormatter.date(from: closingTimeString) else {
            return false
        }

        // 6. Convertendo horários para comparações
        let openHour = calendar.component(.hour, from: openingTime)
        let openMinute = calendar.component(.minute, from: openingTime)
        let closeHour = calendar.component(.hour, from: closingTime)
        let closeMinute = calendar.component(.minute, from: closingTime)

        let currentTotalMinutes = currentHour * 60 + currentMinute
        let openTotalMinutes = openHour * 60 + openMinute
        let closeTotalMinutes = closeHour * 60 + closeMinute

        if closeTotalMinutes < openTotalMinutes {
            // Horário passa da meia-noite (ex: 21:00 – 04:00)
            return currentTotalMinutes >= openTotalMinutes || currentTotalMinutes < closeTotalMinutes
        } else {
            return currentTotalMinutes >= openTotalMinutes && currentTotalMinutes < closeTotalMinutes
        }
    }

}

struct Coordinates: Codable, Equatable {
    let lat: Double
    let lng: Double
}


