//
//  MessageModel.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 14/09/25.
//

import SwiftUI
import FirebaseFirestore
import Foundation
import Combine

struct MessageModel: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var senderId: String
    var timestamp: Date
}
