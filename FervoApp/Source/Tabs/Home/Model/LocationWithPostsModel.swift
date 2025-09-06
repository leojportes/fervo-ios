//
//  LocationWithPostsModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

struct LocationWithPosts: Identifiable, Decodable, Equatable, Hashable {
    var id: String {
        "\(fixedLocation.name)-\(fixedLocation.city)-\(fixedLocation.weekdayText?.hashValue ?? 0)-\(fixedLocation.photoURL.hashValue)"
    }

    let fixedLocation: FixedLocation
    let posts: [Post]?

    enum CodingKeys: String, CodingKey {
        case fixedLocation = "fixedlocation"
        case posts
    }

    var lastThreePosts: [Post] {
        let posts = posts ?? []
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

        let calendar = Calendar.current
        let now = Date()

        let today = formatter.string(from: now).lowercased()
        let yesterday = formatter.string(from: calendar.date(byAdding: .day, value: -1, to: now)!).lowercased()

        if let todayLine = weekDays.first(where: { $0.lowercased().hasPrefix(today) }) {
            if let range = todayLine.range(of: ":") {
                let timePart = todayLine[range.upperBound...].trimmingCharacters(in: .whitespaces)

                if timePart.lowercased() != "fechado" {
                    let parts = timePart.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
                    if parts.count == 2 {
                        let openStr = parts[0]
                        let closeStr = parts[1]

                        let openComponents = openStr.split(separator: ":").compactMap { Int($0) }
                        let closeComponents = closeStr.split(separator: ":").compactMap { Int($0) }

                        if openComponents.count == 2, closeComponents.count == 2 {
                            let openDate = calendar.date(bySettingHour: openComponents[0], minute: openComponents[1], second: 0, of: now)!
                            var closeDate = calendar.date(bySettingHour: closeComponents[0], minute: closeComponents[1], second: 0, of: now)!

                            if closeDate < openDate {
                                closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
                            }

                            if now >= openDate && now <= closeDate {
                                return "Aberto agora até \(closeStr)"
                            } else if now < openDate {
                                return "Abre hoje às \(openStr)"
                            }
                        }
                    }
                }
            }
        }

        if let yesterdayLine = weekDays.first(where: { $0.lowercased().hasPrefix(yesterday) }) {
            if let range = yesterdayLine.range(of: ":") {
                let timePart = yesterdayLine[range.upperBound...].trimmingCharacters(in: .whitespaces)

                let parts = timePart.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count == 2 {
                    let openStr = parts[0]
                    let closeStr = parts[1]

                    let openComponents = openStr.split(separator: ":").compactMap { Int($0) }
                    let closeComponents = closeStr.split(separator: ":").compactMap { Int($0) }

                    if openComponents.count == 2, closeComponents.count == 2 {
                        let openDate = calendar.date(bySettingHour: openComponents[0], minute: openComponents[1], second: 0, of: now)!
                        var closeDate = calendar.date(bySettingHour: closeComponents[0], minute: closeComponents[1], second: 0, of: now)!

                        if closeDate < openDate {
                            closeDate = calendar.date(byAdding: .day, value: 1, to: closeDate)!
                            if now <= closeDate {
                                return "Aberto agora até \(closeStr)"
                            }
                        }
                    }
                }
            }
        }

        for i in 1...7 {
            guard let futureDate = calendar.date(byAdding: .day, value: i, to: now) else { continue }
            let futureDay = formatter.string(from: futureDate).lowercased()

            if let futureLine = weekDays.first(where: { $0.lowercased().hasPrefix(futureDay) }) {
                if let range = futureLine.range(of: ":") {
                    let timePart = futureLine[range.upperBound...].trimmingCharacters(in: .whitespaces)
                    if timePart.lowercased() != "fechado" {
                        let openHour = timePart.components(separatedBy: "-").first!.trimmingCharacters(in: .whitespaces)
                        let dayCapitalized = futureDay.prefix(1).uppercased() + futureDay.dropFirst()
                        return "Abre \(dayCapitalized) às \(openHour)"
                    }
                }
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
            let times = timeRange.components(separatedBy: "-")
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


