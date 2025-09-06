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

        let components = calendar.dateComponents(
            [.minute, .hour, .day, .weekOfYear, .month, .year],
            from: self,
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
