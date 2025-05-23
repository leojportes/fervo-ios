//
//  HomeView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            ScrollView {
                searchTappedView
//                postsView
            }
        }
        .background(Color.FVColor.backgroundDark)
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden()
        .onAppear() {
            customizeNavigationBar()
        }
    }


//    private var postsView: some View {
//        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
//            Section(
//                header:
//                    StickyHeaderView() {
//                        self.selectedLocation = location
//                        self.isShowingLocationDetail = true
//                    }
//                    .padding(.bottom, 20)
//            ) {
//                ForEach(Array(location.lastThreePosts.enumerated()), id: \.element.id) { index, post in
//
//                    let isLast = index == location.lastThreePosts.count - 1
//                    PostCardView(post: post, onCommentTapped: {
//                        self.selectedPostForComments = post
//                        self.isCommentsSheetPresented = true
//                    })
//                    .padding(.horizontal)
//                    if isLast {
//                        Button("Ver mais em \(post.location.name)") {
//                            self.selectedLocation = post.location
//                            self.isShowingLocationDetail = true
//                        }
//                        .font(.subheadline)
//                        .padding(.vertical, 16)
//                    }
//                }
//            }
////            ForEach(viewModel.locationsWithPosts, id: \.id) { location in
////
////            }
//        }
//        .sheet(isPresented: $isShowingLocationDetail) {
//            if let location = selectedLocation {
//                LocalDetailView(location: location)
//            }
//        }
//    }

    // MARK: - Components
    private var headerView: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundColor(.white)

            Text("Olá, Leonardo Portes!")
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var searchTappedView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: {
                print("Clicou na view")
            }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Qual o rolê de hoje?")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        Text("Busque um local ou uma pessoa...")
                            .foregroundColor(.gray)
                            .font(.subheadline)

                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.gray).opacity(0.5))
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.FVColor.cardBackground)
                )
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()
        }
        .padding(.horizontal)
    }

    private func customizeNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.gray
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
