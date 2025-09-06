//
//  SAFARI.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 06/09/25.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .pageSheet // ou .automatic
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Nada necessário aqui
    }
}
