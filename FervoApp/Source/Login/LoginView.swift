//
//  LoginView.swift
//  FervoApp
//
//  Created by gabriel subutzki portes on 02/09/25.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @EnvironmentObject var userSession: UserSession
    @State private var isPasswordVisible = false 

    var body: some View {
        NavigationView {
            ZStack {
                Image("dj_background") // substitua pelo nome da imagem no seu Assets
                       .resizable()
                       .scaledToFill()
                       .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    Text("FERVO")
                        .font(.system(size: 40, weight: .bold, design: .default))
                        .foregroundStyle(Color(red: 0.1622, green: 0.2980, blue: 0.8799))
                        .kerning(20)
                        .padding(.leading, 20)
                        
                    Spacer()

                    VStack(spacing: 16) {
                         TextField("e-mail cadastrado", text: $viewModel.email)
                             .keyboardType(.emailAddress)
                             .autocapitalization(.none)
                             .disableAutocorrection(true)
                             .padding()
                             .background(Color(.white.opacity(0.8)))
                             .cornerRadius(12)
                             .foregroundColor(.gray)

                         ZStack(alignment: .trailing) {
                             Group {
                                 if isPasswordVisible {
                                     TextField("senha cadastrada", text: $viewModel.password)
                                         .frame(height: 30)
                                 } else {
                                     SecureField("senha cadastrada", text: $viewModel.password)
                                         .frame(height: 30)
                                 }
                             }
                             .padding()
                             .background(Color(.white.opacity(0.8)))
                             .cornerRadius(12)
                             .foregroundColor(.gray)

                             Button(action: {
                                 isPasswordVisible.toggle()
                             }) {
                                 Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                     .foregroundColor(.gray)
                             }
                             .padding(.trailing, 16)
                         }
                     }
                     .padding(.horizontal)
                    
                    // Mensagem de erro
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.orange)
                            .font(.caption.bold())
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
                                .background(Color(.blue).opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                    
                    HStack {
                        Text("Não tem uma conta?")
                            .foregroundStyle(.gray)
                        
                        Button {
                            //code
                        } label: {
                            Text("Registre-se!")
                                .foregroundStyle(.white)
                        }

                    }
                    .padding(25)

                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width)
            }
            .navigationBarHidden(true)
        }
    }
}

//#Preview {
//    LoginView()
//        .preferredColorScheme(.dark)
//}

