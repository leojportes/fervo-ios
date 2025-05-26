//
//  HomeView.swift
//  FervoApp
//
//  Created by Leonardo Jose De Oliveira Portes on 22/05/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State var selectedLocation: LocationWithPosts?
    @State var isShowingLocationDetail: Bool = false
    @State var isCommentsSheetPresented: Bool = false
    @State var selectedPostForComments: Post?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            ScrollView {
                searchTappedView

                Divider()
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal)
                    .padding(.bottom)

                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(viewModel.locationsWithPosts, id: \.id) { location in
                        Section(
                            header:
                                StickyHeaderView(location: location) {
                                    // self.selectedLocation = location
                                    // self.isShowingLocationDetail = true
                                }
                        ) {
                            ForEach(Array(location.lastThreePosts.enumerated()), id: \.element.id) { index, post in
                                let isLast = index == location.lastThreePosts.count - 1
                                PostCardView(post: post, onCommentTapped: {
                                    self.selectedPostForComments = post
                                    self.isCommentsSheetPresented = true
                                })
                                .padding(.horizontal)
                                .padding(.top, 12)

                                if isLast {
                                    Button("Ver mais em \(location.fixedLocation.name)") {
                                      //  self.selectedLocation = post.fixedLocation
                                        self.isShowingLocationDetail = true
                                    }
                                    .font(.subheadline)
                                    .padding(.vertical, 16)
                                }
                            }
                        }
                    }
                }
                .bottomSheet(item: $selectedPostForComments) { post in
                    CommentsBottomSheetView(postId: post.id)
                }
                .coordinateSpace(name: "scroll")
            }

        }
        .background(Color.FVColor.backgroundDark)
        .navigationBarBackButtonHidden()
        .onAppear() {
            viewModel.fetch()
            customizeNavigationBar()
        }
    }

    // MARK: - Components
    private var headerView: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundColor(.white)

            Text("Olá, Leonardo Portes!")
                .font(.subheadline)
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
                            .fill(Color.FVColor.headerCardbackgroundColor).opacity(0.5)
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
