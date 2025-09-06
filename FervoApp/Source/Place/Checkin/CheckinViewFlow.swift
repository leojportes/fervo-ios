//
//  CheckinViewFlow.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 28/08/25.
//

import SwiftUI

class CheckinViewFlow: ObservableObject {
    @Published var showFirst = false
    @Published var showSecond = false
    @Published var showThird = false
    @Published var showFourth = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var shoudRequestActiveUsers = false

    func closeAll() {
        showFourth = false
        showSuccess = false
        showError = false
        showThird = false
        showSecond = false
        showFirst = false
    }
}
