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
    @State private var isHidden = true
    
    var body: some View {
        
        NavigationView{
            ZStack{
                Color.fvBackground.edgesIgnoringSafeArea(.all).opacity(0.96) //BackGroundset
                
                Spacer()
                
                VStack{
                    
                    Text("FERVO")
                        .font(.system(size: 40, weight: .bold, design: .default))
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
                                
                                if (isHidden == false) {
                                    TextField("", text: $password, prompt: Text("Senha cadastrada")
                                        .foregroundStyle(.gray))
                                    .padding(.leading, 40)
                                    .opacity(0.5)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .keyboardType(.emailAddress)
                                } else {
                                    SecureField("", text: $password, prompt: Text("Senha cadastrada")
                                        .foregroundStyle(.gray))
                                    .padding(.leading, 40)
                                    .opacity(0.5)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .keyboardType(.emailAddress)
                                }
                                
                                Button {
                                   isHidden.toggle()
                                } label: {
                                    if(isHidden == false){
                                        Image(systemName: "eye")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 22))
                                            .padding(.trailing, 28)
                                    }else {
                                        Image(systemName: "eye.slash")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 22))
                                            .padding(.trailing, 28)
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity ,alignment: .trailing)

                            }

                        }
                        
                        
                    }
                    .padding(.top, 50)
                    
                    VStack{
                        
                        Button {
                            //Code
                        } label: {
                            Text("Esqueceu a senha?")
                                .foregroundStyle(.gray)
                                .font(.title3)
                        }
                        .padding()
                        
                        
                        Button {
                            //code
                        } label: {
                            Text("Entrar")
                        }
                        .frame(width: 340, height: 65, alignment: .center)
                        .background(Color(.blue).opacity(0.8))
                        .foregroundStyle(.white)
                        .cornerRadius(40)
                        .font(.system(size: 20, weight: .bold))
                        
                        HStack{
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
                        
                    }
                    
                }
                
                
            }
        }
    }
}

#Preview {
    LoginViewV3()
}
