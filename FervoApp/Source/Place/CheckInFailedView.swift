//
//  CheckInFailedView.swift
//  FervoApp
//
//  Created by gabriel subutzki portes on 25/08/25.
//

import SwiftUI

struct CheckInFailedView: View {
    @EnvironmentObject var flow: CheckinViewFlow
    @Environment(\.dismiss) private var dismiss
    @StateObject var placeViewModel: PlaceViewModel
    @State var location: LocationWithPosts
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.fvCardBackgorund, .fvHeaderCardbackground]), startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack{
                Text("Check-in")
                    .font(.system(size: 33, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 35)
                
                VStack{
                    Text("Você ainda não chegou no \(location.fixedLocation.name)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.bottom, 1)
                    
                    Text("Ao entrar, responda e ganhe pontos")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(0.6)
                }
                .padding(.top, 60)
                
                
                AsyncImage(url: URL(string: location.fixedLocation.photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .shimmering()
                }
                .frame(width: 170, height: 170)
                .clipShape(Circle())
                .padding(.top, 80)
                
                Spacer()
                
                VStack{
                    Text("Aproxime-se do local correto e realize o check-in \n novamente.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .opacity(0.7)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.bottom, 10)
                    
                    Button {
                        dismiss()
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

//#Preview {
//    CheckInFailedView()
//}
