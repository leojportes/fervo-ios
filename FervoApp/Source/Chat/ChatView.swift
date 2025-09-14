//
//  ChatView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 14/09/25.
//

import SwiftUI

struct ChatView: View {
    @StateObject var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    let userId: String
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(chatViewModel.messages) { message in
                        HStack {
                            if message.senderId == userId {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
            }
            
            HStack {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    chatViewModel.sendMessage(text: messageText, senderId: userId)
                    messageText = ""
                }
            }
            .padding()
        }
    }
}
