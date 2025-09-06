//
//  TooltipView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 28/08/25.
//

import SwiftUI

struct TooltipView: View {
    let text: String
    let onClose: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.black))
        .cornerRadius(20)
        .shadow(radius: 5)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    onClose()
                }
            }
        }
    }
}
