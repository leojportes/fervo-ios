//
//  Date+Ext.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation

extension Date {
    var timeAgoSinceDate: String {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        let now = Date()

        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month],
            from: self,
            to: now
        )

        if let minutes = components.minute, minutes < 60 {
            return minutes == 1 ? "há 1 min" : "há \(minutes) min"
        } else if let hours = components.hour, hours < 24 {
            return hours == 1 ? "há 1h" : "há \(hours)h"
        } else if let days = components.day, days < 7 {
            return days == 1 ? "há 1 dia" : "há \(days) dias"
        } else if let weeks = components.weekOfYear, weeks < 5 {
            return weeks == 1 ? "há 1 semana" : "há \(weeks) semanas"
        } else if let months = components.month, months < 12 {
            return months == 1 ? "há 1 mês" : "há \(months) meses"
        } else {
            let years = calendar.component(.year, from: now) - calendar.component(.year, from: self)
            return years == 1 ? "há 1 ano" : "há \(years) anos"
        }
    }
}
