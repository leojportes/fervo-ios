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
    
    var body: some View{
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [.fvCardBackgorund, .fvBackgroundLogin]), startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)  //Cor de fundo
        
            VStack{
                Text("Bem-vindo(a) \n ao Fervo!")
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                Text("Por favor digite seu Email e Senha para continuar:")
                    .foregroundStyle(.gray.opacity(0.9))
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)
                    .font(.system(size: 16))
                          
                VStack(spacing: 12){
                    Text("Email:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        
                    TextField("Email:", text: $Email)
                        .font(.system(size: 23))
                        .keyboardType(.emailAddress)
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(10)
                        .padding()
                   
                    Text("Senha:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        
                    
                    SecureField("Senha:", text: $password)
                        .font(.system(size: 23))
                        .background(Color.white.opacity(0.4))
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                        .padding()
                                                
                }
                .frame(width: 320, height: 250, alignment: .center)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(22)
                
                //Adicionar o "Esqueceu a senha"
                
                VStack{
                    Button {
                        // ButtonConfig
                    } label: {
                        Text("Entrar")
                    }
                    .frame(width: 200, height: 50, alignment: .center)
                    .background(Color.blue.opacity(0.8))
                    .foregroundStyle(.white)
                    .cornerRadius(20)
                    .font(.title3)
                    .bold()

                }
                .padding(.top, 30)
                
            }
            
        }
    }
}

#Preview{
    LoginViewV2()
}
