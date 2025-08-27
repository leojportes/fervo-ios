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
                        .padding(.trailing, 10)
                        
                        Text("Don't Tell Mama") //Ajustar com o fixedLocation
                            .foregroundStyle(.white)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    

                    Spacer()
                }
                .padding(.bottom, 5)
                .padding(.leading, 17)
                
                Divider()
                    .frame(height: 1)
                    .background(Color.white)
                    .opacity(0.4)
                
              
                Text("Check-in")
                    .font(.system(size: 33, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 28)
                
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
                .padding(.top, 60)
                
                
                // Image(........)
                
                Spacer()
                
                VStack{
                    Text("Aproxime-se do local correto e realize o check-in \n novamente.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .opacity(0.7)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.bottom, 10)
                    
                    Button {
                        // action
                    } label: {
                        Text("Voltar")
                            .frame(width: 340, height: 50, alignment: .center)
                            .background(Color.blue.opacity(0.6))
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                            .font(.title3)
                            .bold()
                            
                    }

                }
                .padding()
                
                
            }

        }
    }
}

#Preview {
    CheckInFailedView()
}
