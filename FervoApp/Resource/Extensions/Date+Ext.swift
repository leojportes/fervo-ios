//
//  Date+Ext.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import Foundation
import Foundation

extension Date {
    var timeAgoSinceDate: String {
        let calendar = Calendar.current
        let now = Date()

        // Simplesmente compare diretamente (não ajuste nada)
        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month, .year],
            from: self,
            to: now
        )

        if let year = components.year, year > 0 {
            return year == 1 ? "há 1 ano" : "há \(year) anos"
        } else if let month = components.month, month > 0 {
            return month == 1 ? "há 1 mês" : "há \(month) meses"
        } else if let week = components.weekOfYear, week > 0 {
            return week == 1 ? "há 1 semana" : "há \(week) semanas"
        } else if let day = components.day, day > 0 {
            return day == 1 ? "há 1 dia" : "há \(day) dias"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "há 1h" : "há \(hour)h"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "há 1 min" : "há \(minute) min"
        } else {
            return "agora mesmo"
        }
    }
}
