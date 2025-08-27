//
//  CheckInFailedView.swift
//  FervoApp
//
//  Created by gabriel subutzki portes on 25/08/25.
//

import SwiftUI

struct CheckInFailedView: View {
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.fvCardBackgorund, .fvHeaderCardbackground]), startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack{
             
                //Header
                HStack{
                    Button {
                        // ação aqui
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.white)
                            .font(.title)
                    }
                    .padding(.trailing, 10)
                    
                    Text("Don't Tell Mama") //Ajustar com o fixedLocation
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()
                }
                .padding()
                
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .opacity(0.4)
                
              
                Text("Check-in")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 25)
                
                VStack{
                    Text("Você ainda não chegou no \("Don't Tell Mama"/* Ajustar com o fixedLocation*/)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.bottom, 1)
                    
                    Text("Ao entrar, responda e ganhe pontos")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(0.6)
                }
                .padding(.top, 50)
                
                
                
                
            }

        }
    }
}

#Preview {
    CheckInFailedView()
}
