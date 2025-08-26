//
//  FixedLocation.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import MapKit

struct FixedLocation: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let placeId: String
    let website: String?
    let rating: Double?
    let priceLevel: Int?
    let photoURL: String
    let location: Coordinates
    let weekdayText: [String]?
    let reviews: [Review]?
    let type: String
    let city: String
    let neighborhood: String
    let userRatingTotal: Int?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name
        case placeId
        case website
        case rating
        case priceLevel
        case photoURL
        case location
        case weekdayText
        case reviews
        case type
        case city
        case neighborhood
        case userRatingTotal = "user_rating_total"
    }

    var mkCoordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng),
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        )
    }

    var mapPriceLevelToString: String {
        guard let level = priceLevel, (0...4).contains(level) else {
            return "N/A"
        }
        return String(repeating: "$", count: level)
    }

    func timeUntilNextOpen() -> String? {
        guard let weekdayText = weekdayText else { return nil }
        let calendar = Calendar.current
        let now = Date()

        // Mapear Apple weekday (1 = Sunday ... 7 = Saturday) para índice do array (segunda = 0)
        let weekdayMap = [1:6, 2:0, 3:1, 4:2, 5:3, 6:4, 7:5]
        let todayIndex = weekdayMap[calendar.component(.weekday, from: now)]!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current

        // Procurar pelo próximo dia que abre
        for offset in 0..<7 {
            let dayIndex = (todayIndex + offset) % 7
            let text = weekdayText[dayIndex]
            let parts = text.components(separatedBy: ": ")
            guard parts.count == 2 else { continue }

            let hoursPart = parts[1].trimmingCharacters(in: .whitespaces)
            if hoursPart.lowercased() == "fechado" { continue }

            // Pegar horário de abertura (primeira parte do range)
            let timeRange = hoursPart.components(separatedBy: "–")
            guard let openingTimeString = timeRange.first?.trimmingCharacters(in: .whitespaces),
                  let openingTime = dateFormatter.date(from: openingTimeString) else { continue }

            // Criar Date de abertura
            var openingComponents = calendar.dateComponents([.year, .month, .day], from: now)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: openingTime)
            openingComponents.hour = timeComponents.hour
            openingComponents.minute = timeComponents.minute

            // Ajustar o dia se não for hoje
            if offset > 0 {
                openingComponents.day! += offset
            }

            guard let openingDate = calendar.date(from: openingComponents) else { continue }

            let interval = Int(openingDate.timeIntervalSince(now))
            if interval > 0 {
                // Formatar resultado
                let days = interval / (60*60*24)
                let hours = (interval % (60*60*24)) / 3600
                let minutes = (interval % 3600) / 60

                if days > 0 {
                    return "Abre em \(days) dia" + (days > 1 ? "s" : "")
                } else if hours > 0 {
                    return "Abre em \(hours)h\(minutes + 1)min"
                } else {
                    return "Abre em \(minutes + 1)min"
                }
            }
        }

        return nil // Nunca abre
    }


}

struct Review: Codable, Equatable, Hashable {
    let text: String
    let authorName: String
    let rating: Double

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case text, rating
    }
}
