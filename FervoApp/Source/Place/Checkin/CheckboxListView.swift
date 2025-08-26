//
//  CheckboxListView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 26/08/25.
//

import SwiftUI

struct CheckboxListView: View {
    @Binding var selectedOption: CrowdLevel

    var body: some View {
        VStack(spacing: 12) {
            ForEach(CrowdLevel.allCases, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                }) {
                    HStack {
                        Image(systemName: selectedOption == option ? "checkmark.square.fill" : "square")
                            .foregroundColor(selectedOption == option ? .fvBackground : .white)

                        Text(option.title)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)

                        option.emojiView

                        Spacer()
                    }
                    .padding(12)
                    .background(selectedOption == option ? .blue : Color.blue.opacity(0.5))
                    .cornerRadius(20)
                }
            }
        }
        .padding()
    }
}

