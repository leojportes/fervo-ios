//
//  MusicalTasteBadgesView.swift
//  FervoApp
//
//  Created by AI Assistant on 12/19/24.
//

import SwiftUI

struct MusicalTasteBadgesView: View {
    let user: UserModel?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gostos musicais")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            if let musicalTastes = user?.musicalTaste, !musicalTastes.isEmpty {
                FlowLayout(items: musicalTastes) { tag in
                    Text(tag)
                        .font(.caption)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            } else {
                Text("Nenhum gosto musical adicionado")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct FlowLayout<Content: View>: View {
    let items: [String]
    let spacing: CGFloat
    let content: (String) -> Content
    
    init(items: [String], spacing: CGFloat = 8, @ViewBuilder content: @escaping (String) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding(.all, 8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        if item == items.last! {
                            width = 0
                        } else {
                            width -= d.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last! {
                            height = 0
                        }
                        return result
                    }
            }
        }
    }
}
