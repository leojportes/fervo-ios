//
//  SelectphotoView.swift
//  FervoApp
//
//  Created by gabriel subutzki portes on 03/09/25.
//

import SwiftUI

struct SelectPhotoView: View {
    var body: some View {
        NavigationView{
            ZStack{
                Color.fvBackground.edgesIgnoringSafeArea(.all).opacity(0.96) //BackGroundset
                
                VStack{
                    Text("Criar conta")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundStyle(.white)
                        .padding(.top, 40)
                    
                    VStack(spacing: 30){
                        Text("Foto de perfil")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .opacity(0.8)
                        
                        ZStack {
                            Circle()
                                .foregroundColor(.white)
                                .frame(width: 240, height: 240)
                                .opacity(0.08)
                            
                            Image(systemName:"person.badge.plus")
                                .font(.system(size: 80))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.top, 80)
                    
                    Spacer()
                    
                    VStack(spacing: 20){
                        Button {
                            //code
                        } label: {
                            Text("Escolher foto")
                        }
                        .frame(width: 350, height: 70, alignment: .center)
                        .background(Color.blue.opacity(0.8))
                        .foregroundStyle(.white)
                        .cornerRadius(50)
                        .font(.title3)
                        .bold()
                        
                        Button {
                            //code
                        } label: {
                            Text("Criar conta sem foto")
                                .opacity(0.4)
                        }
                        .frame(width: 350, height: 70, alignment: .center)
                        .background(Color.gray.opacity(0.178))
                        .foregroundStyle(.white)
                        .cornerRadius(50)
                        .font(.title3)
                        .bold()


                    }
                    .padding(.bottom, 35)
                }
    
            }
            
        }
        
    }
    
}

#Preview {
    SelectPhotoView()
}
