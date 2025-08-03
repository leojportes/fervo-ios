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
                Text("Bem-vindo(a) \n ao Fervo")
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 100)
                VStack(){
                    Text("Email:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        
                    TextField("Email", text: $Email)
                        .keyboardType(.emailAddress)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .padding()
                   
                    Text("Senha:")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        
                    
                    SecureField("Password", text: $password)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .padding()
                }
                .frame(width: 300, height: 300, alignment: .center)
                .background(Color.white.opacity(0.1))
                .cornerRadius(22)
                
                
            }
            
        }
    }
}

#Preview{
    LoginViewV2()
}
