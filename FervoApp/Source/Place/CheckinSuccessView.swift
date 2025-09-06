//
//  CheckinSuccessView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 20/08/25.
//

import SwiftUI
import Lottie

struct CheckinSuccessView: View {
    @EnvironmentObject var flow: CheckinViewFlow
    @State var activeButton: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                      
                        Spacer()
                        Text("Check-in")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxHeight: .infinity, alignment: .center)
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .background(Color.FVColor.backgroundDark)
                    .frame(height: 50)
                }
                contentView
            }
            .background(Color.fvBackground.edgesIgnoringSafeArea(.all))
        }
        .navigationBarBackButtonHidden()
    }

    var contentView: some View {
        VStack {
            Spacer()
            LottieView(animationName: "success_animation", loopMode: .playOnce)
            .frame(width: 250, height: 250)
            Spacer()

            Button(action: {
                flow.closeAll()
            }) {
                Text("Ir para o local")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

}

#Preview {
    CheckinSuccessView()
}
