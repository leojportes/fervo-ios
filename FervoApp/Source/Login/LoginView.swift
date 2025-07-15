//
//  LoginView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/05/25.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // fundo escuro

                VStack(spacing: 24) {
                    Spacer()

                    // Título
                    Text("Bem-vindo de volta 👋")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Faça login para continuar")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Campos de texto
                    VStack(spacing: 16) {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(.gray)

                        SecureField("Senha", text: $viewModel.password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)

                    // Mensagem de erro
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Botão de login
                    Button(action: {
                        viewModel.login(userSession: userSession)
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.8))
                                .cornerRadius(12)
                        } else {
                            Text("Entrar")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)

                    // Link de cadastro
                    HStack {
                        Text("Ainda não tem conta?")
                            .foregroundColor(.gray)
                        Button(action: {
                            // Ação para navegar para cadastro
                        }) {
                            Text("Cadastrar")
                                .foregroundColor(.purple)
                                .fontWeight(.semibold)
                        }
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}

