//
//  LoginViewV3.swift
//  FervoApp
//
//  Created by gabriel subutzki portes on 02/09/25.
//
import SwiftUI

struct LoginViewV3: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe = false
    
    var body: some View {
        
        NavigationView{
            ZStack{
                Color.fvBackground.edgesIgnoringSafeArea(.all).opacity(0.96) //BackGroundset
                
                Spacer()
                
                VStack{
                    
                    Text("FERVO")
                        .font(.system(size: 45, weight: .bold, design: .default))
                        .foregroundStyle(Color(red: 0.1622, green: 0.2980, blue: 0.8799))
                        .kerning(20)
                        .padding(.leading, 20)
                        
                    VStack{
                        Text("Email")
                            .font(.system(size: 24, weight: .regular, design: .default))
                            .foregroundStyle(.white)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .padding(.leading, 10)
                        
                        HStack{
                            ZStack{
                               RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.gray)
                                    .frame(width: 360, height: 65)
                                    .opacity(0.1)
                                
                                TextField("", text: $email, prompt: Text("Email cadastrado")
                                    .foregroundStyle(.gray))
                                    .padding(.leading, 40)
                                    .opacity(0.5)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .keyboardType(.emailAddress)
                                
                                
                            }
                        }
                        
                        Text("Senha")
                            .font(.system(size: 24, weight: .regular, design: .default))
                            .foregroundStyle(.white)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .padding(.leading, 10)

                        
                        HStack{
                            ZStack{
                               RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(.gray)
                                    .frame(width: 360, height: 65)
                                    .opacity(0.1)
                                
                                TextField("", text: $password, prompt: Text("Senha cadastrada")
                                    .foregroundStyle(.gray))
                                    .padding(.leading, 40)
                                    .opacity(0.5)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .keyboardType(.emailAddress)
                            }

                        }
                        
                        
                    }
                    .padding(.top, 80)
                    
                    VStack{
                        Button {
                            //Code
                        } label: {
                            Text("Esqueceu a senha?")
                                .foregroundStyle(.gray)
                                .font(.title3)
                        }
                        .padding()
                        
                        
                    }
                    
                }
                
                
            }
        }
    }
}

#Preview {
    LoginViewV3()
}
