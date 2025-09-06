//
//  String+Ext.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

extension String {
    static var empty: String {
        return ""
    }
}

extension String {
    var timeAgo: String {
        // tenta interpretar a string como ISO8601 primeiro
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date: Date? = isoFormatter.date(from: self)

        // fallback: tenta com DateFormatter padrão (ex: "yyyy-MM-dd HH:mm:ss")
        if date == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            date = formatter.date(from: self)
        }

        guard let parsedDate = date else {
            return self // se não conseguiu parsear, devolve a string original
        }

        let calendar = Calendar.current
        let now = Date()

        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month, .year],
            from: parsedDate,
            to: now
        )

        if let year = components.year, year > 0 {
            return year == 1 ? "1 ano atrás" : "\(year) anos atrás"
        } else if let month = components.month, month > 0 {
            return month == 1 ? "1 mês atrás" : "\(month) meses atrás"
        } else if let week = components.weekOfYear, week > 0 {
            return week == 1 ? "1 semana atrás" : "\(week) semanas atrás"
        } else if let day = components.day, day > 0 {
            return day == 1 ? "ontem" : "\(day) dias atrás"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1h atrás" : "\(hour)h atrás"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 min atrás" : "\(minute) min atrás"
        } else {
            return "agora mesmo"
        }
    }
}

extension String {
    /// Converte a string para Date tentando ISO8601 e depois "yyyy-MM-dd HH:mm:ss"
    var asDate: Date? {
        // tenta ISO8601 primeiro
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: self) {
            return date
        }

        // fallback: "yyyy-MM-dd HH:mm:ss"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // importante se backend manda UTC
        return formatter.date(from: self)
    }
}
