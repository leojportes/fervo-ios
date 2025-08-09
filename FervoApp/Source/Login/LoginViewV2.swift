//
//  LoginViewV2.swift
//  FervoApp
//
//  Created by gabriel subutzki portes on 02/08/25.
//
import SwiftUI

struct LoginViewV2: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe = false
    
    var body: some View{
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [.fvCardBackgorund, .fvHeaderCardbackground]), startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack{
                Text("Bem-vindo(a) \n ao Fervo!")
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)
                
                
                VStack{
                    Text("Email:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 45)
                            
                            TextField("", text: $email, prompt:   Text("Digite aqui seu Email").foregroundStyle(.gray))
                                .padding(.leading, 10)
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .keyboardType(.emailAddress)
                        }
                        .padding(.bottom, 13)
                        
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 35))
                            .padding(.bottom, 13)
                            .padding(.trailing, 6)
                    }
                    .padding(.trailing, 10)
                    .padding(.leading, 10)
                    
                    Text("Senha:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 45)
                            
                            SecureField("", text: $password, prompt:   Text("Digite aqui sua senha").foregroundStyle(.gray))
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .padding(.leading,10)
                            
                            
                        }
                        .padding(.bottom, 13)
                        
                        Image(systemName: "key.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 30))
                            .padding(.bottom, 13)
                            .padding(.trailing, 12)
                            .padding(.leading, 8)
                    }
                    .padding(.trailing, 10)
                    .padding(.leading, 10)
                }
                .frame(width: 380, height: 230, alignment: .center)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                    HStack {
                        
                        Toggle(isOn: $rememberMe) {
                            Text("Lembre-se de mim")
                        }
                        .toggleStyle(CheckboxTogglestyle())
                        
                        
                        Button{
                            
                        }label: {
                            Text("Esqueceu sua senha?")
                                .underline()
                                .foregroundStyle(.white)
                        }
                        .padding(.trailing, 20)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.top, 10)
                    
                    VStack{
                        Button {
                            
                        } label: {
                            Text("Entrar")
                        }
                        .frame(width: 250, height: 70, alignment: .center)
                        .background(Color.blue.opacity(0.8))
                        .foregroundStyle(.white)
                        .cornerRadius(20)
                        .font(.title3)
                        .bold()
                        
                    }
                    .padding(.top, 30)
                    
                    HStack{
                        Text("Ainda não tem uma conta?")
                            .foregroundStyle(.white)
                        Button {
                        
                        } label: {
                            Text("Cadastrar-se")
                                .underline()
                        }
                        
                    }
                    .padding()
                }
                
            }
        }
    
        struct CheckboxTogglestyle: ToggleStyle {
            func makeBody(configuration: Configuration) -> some View {
                Button(action: {
                    configuration.isOn.toggle()
                }) {
                    HStack {
                        Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                            .foregroundColor(configuration.isOn ? .white : .gray)
                            .padding(.leading, 14)
                        configuration.label
                        
                    }
                }
            }
        }
        
    }

    #Preview{
        LoginViewV2()
    }

