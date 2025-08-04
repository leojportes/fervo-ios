//
//  LoginViewV2.swift
//  FervoApp
//
//  Created by gabriel subutzki portes on 02/08/25.
//
import SwiftUI

struct LoginViewV2: View {
    
    @State private var Email: String = ""
    @State private var password: String = ""
    @State private var rememberMe = false
    
    var body: some View{
        ZStack{
            LinearGradient(             //backGroundColor Set
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
                
//                Text("Por favor, digite seu Email e Senha para continuar:")
//                    .foregroundStyle(.gray.opacity(0.9))
//                    .fontWeight(.light)
//                    .multilineTextAlignment(.center)
//                    .padding(.bottom, 40)
//                    .font(.system(size: 16))
                
                VStack(){               //area de login
                    Text("Email:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    HStack(){
                        TextField(text: $Email){
                            Text("Digite aqui seu Email")
                                .foregroundStyle(.gray)
                                
                            
                        }
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .frame(height: 45)
                            .keyboardType(.emailAddress)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.bottom, 13)
                            .padding(.leading,10)
                            
                        
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.white)
                            .font(.system(size:35))
                            .padding(.bottom, 13)
                            .padding(.trailing, 6)
                        
                    }
                    
                    
                    Text("Senha:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                    
                    
                    HStack {
                        SecureField(text: $password){
                            Text("Digite aqui sua senha")
                                .foregroundStyle(.gray)
                                .font(.system(size: 20))
                        }
                            .font(.system(size: 25))
                            .frame(height: 45)
                            .background(Color.white.opacity(0.2))
                            .foregroundStyle(.black.opacity(0.5))
                            .cornerRadius(10)
                            .padding(.leading,10)
                        
                        
                        Image(systemName: "key.fill")
                            .foregroundStyle(.white)
                            .font(.system(size: 30))
                            .padding(.trailing, 15)
                            .padding(.leading, 5)
                        
                        
                    }
                    
                }
                .frame(width: 380, height: 230, alignment: .center)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                HStack {
                    
                    Toggle(isOn: $rememberMe) {
                        Text("Lembre-se de mim")
                    }
                    .toggleStyle(CheckboxTogglestyle())
                    
                    
                    Button{                 //Forguet password Button
                        //Button Configuration
                    }label: {
                        Text("Esqueceu sua senha?")
                            .underline()
                            .foregroundStyle(.white)
                    }
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.top, 10)
                
                VStack{             //Enter button
                    Button {
                        // ButtonConfig
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
                        // ButtonConfig
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
