//
//  DateProvider.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 13/09/25.
//

import Foundation

extension Date {
    // Se setada, `Date.nowMocked` será usada em vez da data real
    static var nowMocked: Date? = nil

    static func nowFixed() -> Date {
        return nowMocked ?? Date()
    }
}
