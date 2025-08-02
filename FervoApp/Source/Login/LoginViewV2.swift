//
//  LoginViewV2.swift
//  FervoApp
//
//  Created by gabriel subutzki portes on 02/08/25.
//
import SwiftUI

struct LoginViewV2: View {
    var body: some View{
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [.fvCardBackgorund, .fvBackground]), startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)  //Cor de fundo
        
            VStack{
                Text("Bem-vindo(a)")
                    .foregroundStyle(.white)
                    .font(.title)
                    .fontWeight(.semibold)
                    
            }
            .padding(.top, -250)
            
        }
    }
}

#Preview{
    LoginViewV2()
}
