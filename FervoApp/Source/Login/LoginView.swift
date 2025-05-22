//
//  LoginView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//


import SwiftUI
//import FirebaseCore

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            // Título
            Text("Fervo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // Email Field
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.gray)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            // Password Field
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                if showPassword {
                    TextField("Senha", text: $password)
                } else {
                    SecureField("Senha", text: $password)
                }
                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            // Botão Entrar
            Button(action: {
                // Lógica de login aqui
            }) {
                Text("Entrar")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}

